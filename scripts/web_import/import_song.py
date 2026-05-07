import argparse
import html as html_lib
import json
import os
import re
import time
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import justext
import requests
from jsonschema import ValidationError, validate
from langchain_core.messages import HumanMessage, SystemMessage
from pydantic import BaseModel, Field

try:
    from .llm_client import build_chat_model, resolve_config
except ImportError:
    from llm_client import build_chat_model, resolve_config


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_SCHEMA_PATH = SCRIPT_DIR / "songbook_schema.json"
DEFAULT_PROMPT_PATH = SCRIPT_DIR / "prompts" / "song_extraction_prompt.txt"
SECTION_RE = re.compile(r"^\[\s*(.+?)\s*\]$")
ROOT_RE = re.compile(r"^[A-G](?:#|b)?")


class SongbookJsonOutput(BaseModel):
    song: Dict[str, Any] = Field(
        ...,
        description="Songbook song JSON object matching the app schema.",
    )


def load_prompt_template(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def load_schema(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def fetch_html(
    url: str,
    timeout: int = 30,
    cookie: Optional[str] = None,
    proxy: Optional[str] = None,
) -> str:
    session = requests.Session()
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/124.0.0.0 Safari/537.36"
        ),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": "https://www.ultimate-guitar.com/",
    }
    if cookie:
        headers["Cookie"] = cookie

    proxies = {"http": proxy, "https": proxy} if proxy else None

    candidate_urls = [url]
    if "tabs.ultimate-guitar.com/tab/" in url:
        candidate_urls.append(url.replace("tabs.ultimate-guitar.com", "www.ultimate-guitar.com"))

    last_error: Optional[Exception] = None
    for candidate_url in candidate_urls:
        try:
            response = session.get(
                candidate_url,
                timeout=timeout,
                headers=headers,
                proxies=proxies,
            )
            response.raise_for_status()
            return response.text
        except requests.HTTPError as exc:
            last_error = exc
            status = exc.response.status_code if exc.response is not None else None
            if status != 403:
                raise
        except requests.RequestException as exc:
            last_error = exc

    raise RuntimeError(
        "Failed to download page content (403/blocked). Try the same path on "
        "https://www.ultimate-guitar.com, or provide cookies/proxy if your network blocks it."
    ) from last_error


def fetch_html_with_selenium(url: str, timeout: int = 30, headless: bool = True) -> str:
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options
    except ImportError as exc:
        raise ImportError(
            "Selenium mode requested, but 'selenium' is not installed. "
            "Install requirements first."
        ) from exc

    options = Options()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument(
        "--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    )

    driver = webdriver.Chrome(options=options)
    driver.set_page_load_timeout(timeout)
    try:
        driver.get(url)
        time.sleep(3)
        return driver.page_source
    finally:
        driver.quit()


def strip_boilerplate(html: str) -> str:
    ug_content = extract_ultimate_guitar_tab_content(html)
    if ug_content:
        return ug_content

    paragraphs = justext.justext(html, justext.get_stoplist("English"))
    lines: List[str] = []
    for para in paragraphs:
        text = para.text.strip()
        if not text or para.is_boilerplate:
            continue
        lines.append(text)
    cleaned = "\n".join(lines).strip()
    if cleaned:
        return cleaned

    # Final fallback: plain HTML text extraction for heavily script-gated pages.
    text_only = re.sub(r"<script\b[^>]*>[\s\S]*?</script>", "\n", html, flags=re.IGNORECASE)
    text_only = re.sub(r"<style\b[^>]*>[\s\S]*?</style>", "\n", text_only, flags=re.IGNORECASE)
    text_only = re.sub(r"<[^>]+>", " ", text_only)
    text_only = html_lib.unescape(text_only)
    text_only = re.sub(r"[ \t]+", " ", text_only)
    text_only = re.sub(r"\n{2,}", "\n", text_only)
    return text_only.strip()


def extract_ultimate_guitar_tab_content(html: str) -> Optional[str]:
    patterns = [
        r'"wiki_tab"\s*:\s*\{[\s\S]*?"content"\s*:\s*"((?:\\.|[^"\\])*)"',
        r'"content"\s*:\s*"((?:\\.|[^"\\])*)"\s*,\s*"revision_id"',
    ]
    for pattern in patterns:
        match = re.search(pattern, html)
        if not match:
            continue
        escaped = match.group(1)
        try:
            decoded = json.loads(f"\"{escaped}\"")
        except json.JSONDecodeError:
            continue
        if "[" in decoded or "\n" in decoded:
            return decoded

    # Fallback for pages where JSON blocks are HTML-escaped or nested in script blobs.
    script_blobs = re.findall(r"<script[^>]*>([\s\S]*?)</script>", html, flags=re.IGNORECASE)
    for blob in script_blobs:
        unescaped_blob = html_lib.unescape(blob)
        for pattern in patterns:
            match = re.search(pattern, unescaped_blob)
            if not match:
                continue
            escaped = match.group(1)
            try:
                decoded = json.loads(f"\"{escaped}\"")
            except json.JSONDecodeError:
                continue
            if "[" in decoded or "\n" in decoded:
                return decoded
    return None


def parse_json_maybe_wrapped(content: str) -> Dict[str, Any]:
    payload = content.strip()
    if payload.startswith("```"):
        payload = re.sub(r"^```(?:json)?\s*", "", payload)
        payload = re.sub(r"\s*```$", "", payload)
    start = payload.find("{")
    end = payload.rfind("}")
    if start >= 0 and end >= 0:
        payload = payload[start : end + 1]
    return json.loads(payload)


def ensure_uuid(value: Any) -> str:
    if isinstance(value, str):
        try:
            uuid.UUID(value)
            return value
        except ValueError:
            pass
    return str(uuid.uuid4())


def sanitize_lyric(text: Any) -> str:
    if text is None:
        return ""
    return str(text).replace("\t", "    ").rstrip()


def normalize_chord(raw_chord: Any) -> Dict[str, Any]:
    chord = raw_chord if isinstance(raw_chord, dict) else {}

    def pick_enum(value: Any, allowed: List[str], default: str) -> str:
        return value if isinstance(value, str) and value in allowed else default

    def pick_nullable_enum(value: Any, allowed: List[str]) -> Optional[str]:
        if value is None:
            return None
        return value if isinstance(value, str) and value in allowed else None

    return {
        "id": ensure_uuid(chord.get("id")),
        "root_note": pick_enum(chord.get("root_note"), ["A", "B", "C", "D", "E", "F", "G"], "C"),
        "root_note_alteration": pick_enum(chord.get("root_note_alteration"), ["natural", "flat", "sharp"], "natural"),
        "chord_type": pick_enum(
            chord.get("chord_type"),
            ["major", "minor", "seventh", "diminished", "augmented", "power"],
            "major",
        ),
        "seventh_type": pick_nullable_enum(chord.get("seventh_type"), ["major", "minor", "dominant", "halfDimished"]),
        "extended_type": pick_nullable_enum(chord.get("extended_type"), ["ninth", "eleventh", "thirteenth"]),
        "suspended_type": pick_nullable_enum(chord.get("suspended_type"), ["second", "fourth"]),
        "added_type": pick_nullable_enum(chord.get("added_type"), ["second", "ninth"]),
        "added_alteration": pick_enum(chord.get("added_alteration"), ["natural", "flat", "sharp"], "natural"),
        "bass_note": pick_nullable_enum(chord.get("bass_note"), ["A", "B", "C", "D", "E", "F", "G"]),
        "bass_note_alteration": pick_nullable_enum(chord.get("bass_note_alteration"), ["natural", "flat", "sharp"]),
        "image_path": chord.get("image_path") if isinstance(chord.get("image_path"), str) else None,
    }


def parse_chord_symbol(token: str) -> Optional[Dict[str, Any]]:
    t = token.strip().strip("|").strip()
    if not t or t in {".", "./.", "/"}:
        return None
    match = ROOT_RE.match(t)
    if not match:
        return None

    root_raw = match.group(0)
    root_note = root_raw[0]
    root_alt = "natural"
    if len(root_raw) > 1:
        root_alt = "sharp" if root_raw[1] == "#" else "flat"

    suffix_and_bass = t[len(root_raw) :]
    bass_note = None
    bass_alt = None
    if "/" in suffix_and_bass:
        left, right = suffix_and_bass.rsplit("/", 1)
        suffix = left
        if right and right[0] in "ABCDEFG":
            bass_note = right[0]
            if len(right) > 1 and right[1] in "#b":
                bass_alt = "sharp" if right[1] == "#" else "flat"
    else:
        suffix = suffix_and_bass

    suffix_lower = suffix.lower()
    chord_type = "major"
    seventh_type = None
    extended_type = None
    suspended_type = None
    added_type = None
    added_alteration = "natural"

    if "m7b5" in suffix_lower or "ø7" in suffix:
        chord_type = "seventh"
        seventh_type = "halfDimished"
    elif "maj7" in suffix_lower or "M7" in suffix:
        chord_type = "seventh"
        seventh_type = "major"
    elif "m7" in suffix_lower:
        chord_type = "seventh"
        seventh_type = "minor"
    elif "7" in suffix_lower:
        chord_type = "seventh"
        seventh_type = "dominant"
    elif "dim" in suffix_lower:
        chord_type = "diminished"
    elif "aug" in suffix_lower or "+" in suffix:
        chord_type = "augmented"
    elif suffix_lower.startswith("m"):
        chord_type = "minor"
    elif "5" in suffix_lower:
        chord_type = "power"

    if "13" in suffix_lower:
        extended_type = "thirteenth"
    elif "11" in suffix_lower:
        extended_type = "eleventh"
    elif "9" in suffix_lower:
        extended_type = "ninth"

    if "sus2" in suffix_lower:
        suspended_type = "second"
    elif "sus4" in suffix_lower or "sus" in suffix_lower:
        suspended_type = "fourth"

    if "add#9" in suffix_lower:
        added_type = "ninth"
        added_alteration = "sharp"
    elif "addb9" in suffix_lower:
        added_type = "ninth"
        added_alteration = "flat"
    elif "add9" in suffix_lower:
        added_type = "ninth"
    elif "add2" in suffix_lower:
        added_type = "second"

    return {
        "id": str(uuid.uuid4()),
        "root_note": root_note,
        "root_note_alteration": root_alt,
        "chord_type": chord_type,
        "seventh_type": seventh_type,
        "extended_type": extended_type,
        "suspended_type": suspended_type,
        "added_type": added_type,
        "added_alteration": added_alteration,
        "bass_note": bass_note,
        "bass_note_alteration": bass_alt,
        "image_path": None,
    }


def parse_chord_line(line: str) -> List[Dict[str, Any]]:
    cleaned = line.replace("|", " ")
    steps: List[Dict[str, Any]] = []
    for match in re.finditer(r"[A-G](?:#|b)?[A-Za-z0-9#/+()\-]*", cleaned):
        token = match.group(0).strip()
        chord = parse_chord_symbol(token)
        if not chord:
            continue
        steps.append(
            {
                "id": str(uuid.uuid4()),
                "step": max(0, match.start()),
                "chord": chord,
            }
        )
    return steps


def is_likely_chord_line(line: str) -> bool:
    stripped = line.strip()
    if not stripped:
        return False
    if SECTION_RE.match(stripped):
        return False
    steps = parse_chord_line(stripped)
    if not steps:
        return False
    tokens = [t for t in re.split(r"\s+", stripped.replace("|", " ").strip()) if t]
    if not tokens:
        return False
    # chord sheets usually have high chord token density.
    return len(steps) >= max(1, len(tokens) // 2)


def parse_chord_sheet_text(cleaned_text: str, fallback_title: str = "Imported Song") -> Optional[Dict[str, Any]]:
    lines = [line.rstrip() for line in cleaned_text.splitlines()]
    sections: List[Dict[str, Any]] = []
    current_name = "Song"
    current_phrases: List[Dict[str, Any]] = []
    section_pos = 0
    phrase_pos = 0
    idx = 0

    def flush_section() -> None:
        nonlocal section_pos, phrase_pos, current_phrases, current_name
        if not current_phrases:
            return
        sections.append(
            {
                "id": str(uuid.uuid4()),
                "name": current_name,
                "position": section_pos,
                "phrases": current_phrases,
            }
        )
        section_pos += 1
        phrase_pos = 0
        current_phrases = []

    while idx < len(lines):
        raw = lines[idx]
        line = raw.strip()
        if not line:
            idx += 1
            continue

        section_match = SECTION_RE.match(line)
        if section_match:
            flush_section()
            current_name = section_match.group(1).strip() or "Section"
            idx += 1
            continue

        if is_likely_chord_line(line):
            steps = parse_chord_line(line)
            lyric = ""
            if idx + 1 < len(lines):
                next_line = lines[idx + 1].strip()
                if next_line and not SECTION_RE.match(next_line) and not is_likely_chord_line(next_line):
                    lyric = next_line
                    idx += 1
            current_phrases.append(
                {
                    "id": str(uuid.uuid4()),
                    "position": phrase_pos,
                    "repeats": 1,
                    "lyric": {"id": str(uuid.uuid4()), "text": lyric},
                    "chordSequence": {
                        "id": str(uuid.uuid4()),
                        "sequence": steps,
                    },
                }
            )
            phrase_pos += 1
            idx += 1
            continue

        # Lyric-only phrase fallback.
        current_phrases.append(
            {
                "id": str(uuid.uuid4()),
                "position": phrase_pos,
                "repeats": 1,
                "lyric": {"id": str(uuid.uuid4()), "text": line},
                "chordSequence": {"id": str(uuid.uuid4()), "sequence": []},
            }
        )
        phrase_pos += 1
        idx += 1

    flush_section()
    if not sections:
        return None

    return {
        "id": str(uuid.uuid4()),
        "title": fallback_title,
        "key": None,
        "artist": None,
        "sections": sections,
    }


def strip_leading_underscore_keys(obj: Any) -> Any:
    """Remove LLM junk keys like '-id' that break round-trips and confuse readers."""
    if isinstance(obj, dict):
        cleaned = {k: strip_leading_underscore_keys(v) for k, v in obj.items() if not str(k).startswith("-")}
        return cleaned
    if isinstance(obj, list):
        return [strip_leading_underscore_keys(x) for x in obj]
    return obj


def postprocess_song(song: Dict[str, Any]) -> Dict[str, Any]:
    song = strip_leading_underscore_keys(song)
    song["id"] = ensure_uuid(song.get("id"))
    song["title"] = str(song.get("title") or "Imported Song").strip() or "Imported Song"
    if "artist" in song and song["artist"] is not None:
        song["artist"] = str(song["artist"]).strip() or None
    if "key" in song and song["key"] is not None:
        song["key"] = str(song["key"]).strip() or None

    sections = song.get("sections") or []
    if not isinstance(sections, list):
        sections = []
    for s_idx, section in enumerate(sections):
        section["id"] = ensure_uuid(section.get("id"))
        section["name"] = str(section.get("name") or f"Section {s_idx + 1}").strip() or f"Section {s_idx + 1}"
        section["position"] = s_idx

        phrases = section.get("phrases") or []
        if not isinstance(phrases, list):
            phrases = []
        for p_idx, phrase in enumerate(phrases):
            phrase["id"] = ensure_uuid(phrase.get("id"))
            phrase["position"] = p_idx
            phrase["repeats"] = int(phrase.get("repeats") or 1)
            if phrase["repeats"] < 1:
                phrase["repeats"] = 1

            lyric = phrase.get("lyric") or {}
            phrase["lyric"] = {
                "id": ensure_uuid(lyric.get("id") if isinstance(lyric, dict) else None),
                "text": sanitize_lyric(lyric.get("text") if isinstance(lyric, dict) else ""),
            }

            raw_sequence = phrase.get("chordSequence")
            if isinstance(raw_sequence, dict):
                sequence = raw_sequence
            elif isinstance(raw_sequence, list):
                # Common malformed LLM shape: chordSequence emitted directly as list of steps.
                sequence = {"id": None, "sequence": raw_sequence}
            else:
                sequence = {}

            sequence["id"] = ensure_uuid(sequence.get("id"))
            steps = sequence.get("sequence")
            if not isinstance(steps, list):
                steps = []

            normalized_steps = []
            for step in steps:
                if not isinstance(step, dict):
                    continue
                try:
                    step_value = int(step.get("step", 0))
                except (TypeError, ValueError):
                    step_value = 0
                if step_value < 0:
                    step_value = 0
                normalized_steps.append(
                    {
                        "id": ensure_uuid(step.get("id")),
                        "step": step_value,
                        "chord": normalize_chord(step.get("chord", {})),
                    }
                )
            normalized_steps.sort(key=lambda x: x["step"])
            sequence["sequence"] = normalized_steps
            phrase["chordSequence"] = sequence
        section["phrases"] = phrases
    song["sections"] = sections
    return song


def validate_semantics(song: Dict[str, Any], max_step_absolute: int = 4000) -> List[str]:
    """Validate song shape. Chord `step` is a column offset; it can exceed lyric length."""
    errors: List[str] = []
    sections = song.get("sections", [])
    if not sections:
        errors.append("Song must contain at least one section.")
        return errors

    for expected_pos, section in enumerate(sections):
        if section.get("position") != expected_pos:
            errors.append(f"Section '{section.get('name', '?')}' has non-sequential position.")
        name = str(section.get("name") or "").strip()
        if not name:
            errors.append(f"Section at position {expected_pos} has empty name.")

        phrases = section.get("phrases", [])
        if not phrases:
            errors.append(f"Section '{name or expected_pos}' has no phrases.")
            continue

        for phrase_idx, phrase in enumerate(phrases):
            if phrase.get("position") != phrase_idx:
                errors.append(f"Phrase in section '{name or expected_pos}' has non-sequential position.")
            sequence = ((phrase.get("chordSequence") or {}).get("sequence")) or []
            prev_step = -1
            for step_obj in sequence:
                step = step_obj.get("step", -1)
                if not isinstance(step, int):
                    errors.append(f"Non-integer chord step in section '{name}'.")
                    continue
                if step < 0:
                    errors.append(f"Negative chord step in section '{name}'.")
                if step < prev_step:
                    errors.append(f"Chord steps must be monotonic in section '{name}'.")
                prev_step = step
                if step > max_step_absolute:
                    errors.append(
                        f"Chord step {step} exceeds absolute limit {max_step_absolute} in section '{name}'."
                    )
    return errors


def validate_song(song: Dict[str, Any], schema: Dict[str, Any]) -> List[str]:
    errors: List[str] = []
    try:
        validate(instance=song, schema=schema)
    except ValidationError as exc:
        errors.append(f"Schema validation failed: {exc.message}")
    errors.extend(validate_semantics(song))
    return errors


def invoke_llm_json(
    llm: Any,
    prompt_template: str,
    cleaned_text: str,
    source_url: str,
    previous_output: Optional[str] = None,
    previous_errors: Optional[List[str]] = None,
) -> Tuple[str, Dict[str, Any]]:
    user_prompt = prompt_template.format(
        source_url=source_url,
        cleaned_text=cleaned_text,
    )
    if previous_output and previous_errors:
        user_prompt += (
            "\n\nThe previous output was invalid. Repair it.\n"
            f"Validation errors:\n- " + "\n- ".join(previous_errors) + "\n\n"
            f"Previous output:\n{previous_output}\n"
        )

    messages = [
        SystemMessage(
            content=(
                "You must return structured output that conforms to the provided schema. "
                "Do not return markdown."
            )
        ),
        HumanMessage(content=user_prompt),
    ]

    # Prefer provider-native structured output when available.
    try:
        structured_llm = llm.with_structured_output(SongbookJsonOutput)
        response = structured_llm.invoke(messages)
        if isinstance(response, SongbookJsonOutput):
            parsed = response.song
        elif isinstance(response, dict) and "song" in response:
            parsed = response["song"]
        else:
            parsed = dict(response)
        return json.dumps(parsed), parsed
    except Exception:
        # Fallback for providers/models that do not support structured output.
        response = llm.invoke(messages)
        content = response.content if hasattr(response, "content") else str(response)
        if isinstance(content, list):
            content = "\n".join(str(part) for part in content)
        parsed = parse_json_maybe_wrapped(str(content))
        return str(content), parsed


def run_pipeline(
    url: str,
    provider: Optional[str],
    model: Optional[str],
    temperature: Optional[float],
    max_retries: int,
    ollama_base_url: Optional[str],
    cookie: Optional[str],
    proxy: Optional[str],
    use_selenium: bool,
    selenium_headed: bool,
    print_capture: bool,
    print_html_snippet: bool,
    skip_rule_parser: bool,
    text_file: Optional[Path],
    title_override: Optional[str],
    artist_override: Optional[str],
    verbose: bool,
    prompt_path: Path,
    schema_path: Path,
) -> Dict[str, Any]:
    prompt_template = load_prompt_template(prompt_path)
    schema = load_schema(schema_path)
    if text_file is not None:
        cleaned_text = text_file.read_text(encoding="utf-8")
        html = ""
    elif use_selenium:
        html = fetch_html_with_selenium(url, headless=not selenium_headed)
        cleaned_text = strip_boilerplate(html)
    else:
        html = fetch_html(url, cookie=cookie, proxy=proxy)
        cleaned_text = strip_boilerplate(html)
    if print_html_snippet:
        snippet = html[:4000]
        print("===== RAW_HTML_SNIPPET_START =====")
        print(snippet)
        print("===== RAW_HTML_SNIPPET_END =====")
        print(f"RAW_HTML_LENGTH={len(html)}")
    if print_capture:
        print("===== CAPTURED_TEXT_START =====")
        print(cleaned_text)
        print("===== CAPTURED_TEXT_END =====")
    if not cleaned_text.strip():
        raise RuntimeError("No meaningful text remained after boilerplate stripping.")

    if not skip_rule_parser:
        fallback_title = (title_override or "").strip() or "Imported Song"
        parsed_direct = parse_chord_sheet_text(cleaned_text, fallback_title=fallback_title)
        if parsed_direct:
            if artist_override:
                parsed_direct["artist"] = artist_override.strip() or None
            if title_override:
                parsed_direct["title"] = title_override.strip()
            processed_direct = postprocess_song(parsed_direct)
            direct_errors = validate_song(processed_direct, schema)
            if not direct_errors:
                if verbose:
                    print("Used deterministic chord-sheet parser (rule path).", flush=True)
                return processed_direct
            if verbose:
                print("Rule parser produced JSON but validation failed; falling back to LLM:", flush=True)
                for err in direct_errors:
                    print(f"  - {err}", flush=True)

    config = resolve_config(provider, model, temperature, ollama_base_url)
    llm = build_chat_model(config)

    previous_output: Optional[str] = None
    previous_errors: Optional[List[str]] = None

    for _ in range(max_retries + 1):
        raw_output, candidate = invoke_llm_json(
            llm=llm,
            prompt_template=prompt_template,
            cleaned_text=cleaned_text,
            source_url=url,
            previous_output=previous_output,
            previous_errors=previous_errors,
        )
        processed = postprocess_song(candidate)
        errors = validate_song(processed, schema)
        if not errors:
            return processed

        previous_output = raw_output
        previous_errors = errors

    raise RuntimeError(
        "Failed to produce valid Songbook JSON after retries:\n- "
        + "\n- ".join(previous_errors or ["unknown error"])
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Import a web tab page into Songbook JSON.")
    parser.add_argument(
        "url",
        nargs="?",
        default="",
        help="Page URL (optional if --text-file is set).",
    )
    parser.add_argument("--output", default="imported_song.json", help="Output JSON path.")
    parser.add_argument("--provider", choices=["ollama", "openai", "gemini"], help="LLM provider.")
    parser.add_argument("--model", help="Model name for selected provider.")
    parser.add_argument("--temperature", type=float, default=None, help="Model temperature.")
    parser.add_argument(
        "--max-retries",
        type=int,
        default=int(os.getenv("SONGBOOK_LLM_MAX_RETRIES", "3")),
        help="LLM retry attempts for validation repair.",
    )
    parser.add_argument("--ollama-base-url", default=None, help="Ollama base URL.")
    parser.add_argument("--cookie", default=None, help="Raw Cookie header value for authenticated requests.")
    parser.add_argument("--cookie-file", type=Path, default=None, help="Path to file containing raw Cookie header value.")
    parser.add_argument("--proxy", default=None, help="HTTP(S) proxy URL, e.g. http://127.0.0.1:8080")
    parser.add_argument(
        "--use-selenium",
        action="store_true",
        help="Fetch page with headless Chrome via Selenium (for JS/bot-protected pages).",
    )
    parser.add_argument(
        "--selenium-headed",
        action="store_true",
        help="Run Selenium with visible browser window (non-headless). Use with --use-selenium.",
    )
    parser.add_argument(
        "--print-capture",
        action="store_true",
        help="Print extracted page text to console before LLM processing.",
    )
    parser.add_argument(
        "--print-html-snippet",
        action="store_true",
        help="Print first 4000 chars of raw HTML and total length for fetch debugging.",
    )
    parser.add_argument(
        "--skip-rule-parser",
        action="store_true",
        help="Skip deterministic chord-sheet parser and force LLM extraction.",
    )
    parser.add_argument(
        "--text-file",
        type=Path,
        default=None,
        help="Use this file as chord/lyric source (UTF-8). Skips HTTP fetch when set.",
    )
    parser.add_argument("--title", default=None, help="Override song title (also used as rule-parser default).")
    parser.add_argument("--artist", default=None, help="Override artist on rule-parser output.")
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print whether rule parser succeeded and validation errors if it did not.",
    )
    parser.add_argument("--schema-path", type=Path, default=DEFAULT_SCHEMA_PATH)
    parser.add_argument("--prompt-path", type=Path, default=DEFAULT_PROMPT_PATH)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    cookie = args.cookie
    if args.cookie_file:
        cookie = args.cookie_file.read_text(encoding="utf-8").strip()

    if args.text_file is None and not (args.url and str(args.url).strip()):
        raise SystemExit("Provide a URL or --text-file.")

    url = (args.url or "").strip()
    if not url and args.text_file is not None:
        url = f"file://{args.text_file.resolve()}"

    result = run_pipeline(
        url=url or "https://local/import",
        provider=args.provider,
        model=args.model,
        temperature=args.temperature,
        max_retries=args.max_retries,
        ollama_base_url=args.ollama_base_url,
        cookie=cookie,
        proxy=args.proxy,
        use_selenium=args.use_selenium,
        selenium_headed=args.selenium_headed,
        print_capture=args.print_capture,
        print_html_snippet=args.print_html_snippet,
        skip_rule_parser=args.skip_rule_parser,
        text_file=args.text_file,
        title_override=args.title,
        artist_override=args.artist,
        verbose=args.verbose,
        prompt_path=args.prompt_path,
        schema_path=args.schema_path,
    )
    output_path = Path(args.output)
    output_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(f"Wrote Songbook JSON to {output_path}")


if __name__ == "__main__":
    main()
