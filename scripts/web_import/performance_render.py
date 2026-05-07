"""
Render Songbook JSON to plain text for performance, matching PlainTextSongRenderer / PlainTextChordRenderer.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Optional


def chord_short_name(chord: Dict[str, Any]) -> str:
    """Match PlainTextChordRenderer.renderShortName (Swift)."""
    root = str(chord.get("root_note") or "C")
    alt = chord.get("root_note_alteration") or "natural"
    if alt == "flat":
        root += "b"
    elif alt == "sharp":
        root += "#"

    ctype = chord.get("chord_type") or "major"
    seventh = chord.get("seventh_type")
    short = root

    if ctype == "major":
        pass
    elif ctype == "minor":
        short += "m"
    elif ctype == "seventh":
        if seventh == "major":
            short += "maj7"
        elif seventh == "minor":
            short += "m7"
        elif seventh == "dominant":
            short += "7"
        elif seventh == "halfDimished":
            short += "m7(b5)"
    elif ctype == "augmented":
        short += "aug"
    elif ctype == "diminished":
        short += "dim"
    elif ctype == "power":
        short += "5"

    added_type = chord.get("added_type")
    added_alt = chord.get("added_alteration") or "natural"
    if added_type in ("ninth", "second"):
        alteration = ""
        if added_alt == "flat":
            alteration = "b"
        elif added_alt == "sharp":
            alteration = "#"
        short += f"{alteration}9"

    ext = chord.get("extended_type")
    if ext == "eleventh":
        short += "(add11)"
    elif ext == "ninth":
        short += "(add9)"
    elif ext == "thirteenth":
        short += "(add13)"

    sus = chord.get("suspended_type")
    if sus == "fourth":
        short += "sus4"
    elif sus == "second":
        short += "sus2"

    bass = chord.get("bass_note")
    if bass:
        short += f"/{bass}"
        bass_alt = chord.get("bass_note_alteration")
        if bass_alt == "flat":
            short += "b"
        elif bass_alt == "sharp":
            short += "#"

    return short


def _sorted_steps(sequence: Dict[str, Any]) -> List[Dict[str, Any]]:
    seq = sequence.get("sequence") or []
    if not isinstance(seq, list):
        return []
    out = [s for s in seq if isinstance(s, dict)]
    out.sort(key=lambda s: int(s.get("step", 0) or 0))
    return out


def render_phrase(phrase: Dict[str, Any]) -> str:
    """Match PlainTextSongRenderer.render(phrase:) without transposition."""
    lyric_obj = phrase.get("lyric") or {}
    working_lyrics = str(lyric_obj.get("text") or "")
    raw_seq = phrase.get("chordSequence") or {}
    if isinstance(raw_seq, list):
        sequence_obj = {"sequence": raw_seq}
    else:
        sequence_obj = raw_seq if isinstance(raw_seq, dict) else {}
    sequence = _sorted_steps(sequence_obj)

    chord_line = ""
    lyric_line = ""
    chord_offset = 0
    sequence_offset = 0

    if len(working_lyrics) == 0:
        for step in sequence:
            ch = step.get("chord") or {}
            chord_line += chord_short_name(ch)
            chord_line += " "
    else:
        remaining_chords = len([s for s in sequence if s.get("chord")])

        for i in range(len(working_lyrics)):
            next_step = next((s for s in sequence if int(s.get("step", -1)) == i), None)
            if next_step is not None:
                chord = next_step.get("chord") or {}
                remaining_chords -= 1
                short_name = chord_short_name(chord)
                chord_line += short_name

                next_after = next((s for s in sequence if int(s.get("step", -1)) > i), None)
                if next_after is not None:
                    na_step = int(next_after.get("step", 0))
                    if na_step < i + len(short_name):
                        if len(short_name) > 1:
                            sequence_offset = len(short_name)
                        else:
                            sequence_offset = 1 - len(short_name)
                    else:
                        if len(short_name) > 1:
                            chord_offset = len(short_name) - 1
            else:
                if chord_offset == 0:
                    chord_line += " "
                elif chord_offset < 0:
                    chord_offset += 1
                elif chord_offset > 0:
                    chord_offset -= 1

            if i < len(working_lyrics):
                lyric_line += working_lyrics[i]

            if sequence_offset > 0:
                for _ in range(sequence_offset - 1):
                    lyric_line += " "
                sequence_offset = 0

        if remaining_chords > 0:
            for idx in range(remaining_chords, len(sequence)):
                step = sequence[idx]
                chord_line += f"{chord_short_name(step.get('chord') or {})} "

    repeats = int(phrase.get("repeats") or 1)
    if repeats > 1:
        padded = chord_line.ljust(len(lyric_line)) if lyric_line else chord_line
        if padded == "":
            padded = f"{chord_line} x{repeats}"
        else:
            padded += f" x{repeats}"
        return f"{padded}\n{lyric_line}"
    return f"{chord_line}\n{lyric_line}"


def render_section(section: Dict[str, Any]) -> str:
    raw_name = str(section.get("name") or "").strip()
    header = f"[{raw_name}]" if raw_name else "[Section]"
    phrases = section.get("phrases") or []
    if not isinstance(phrases, list):
        phrases = []
    phrases = sorted(phrases, key=lambda p: int(p.get("position", 0) or 0))
    parts: List[str] = []
    for phrase in phrases:
        if not isinstance(phrase, dict):
            continue
        parts.append(render_phrase(phrase))
        parts.append("\n")
    body = "".join(parts)
    return f"{header}\n\n{body}" if body else f"{header}\n"


def render_song(song: Dict[str, Any]) -> str:
    title = str(song.get("title") or "")
    lines: List[str] = [title, "-" * len(title) if title else ""]

    key = song.get("key")
    if key:
        lines.append(f"Key: {key}")
        lines.append("")

    sections = song.get("sections") or []
    if not isinstance(sections, list):
        sections = []
    sections = sorted(sections, key=lambda s: int(s.get("position", 0) or 0))
    for section in sections:
        if isinstance(section, dict):
            lines.append(render_section(section))
    return "\n".join(lines) + "\n"


def load_song_json(path: Path) -> Dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("JSON root must be an object")
    return data


def song_from_path(path: Path) -> str:
    return render_song(load_song_json(path))
