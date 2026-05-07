# Web Song Import Script

Standalone Python pipeline that fetches tab HTML, removes boilerplate with `jusText`, then asks an LLM (via LangChain) to produce Songbook-compatible JSON.

## Install

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r scripts/web_import/requirements.txt
```

## Usage

```bash
python scripts/web_import/import_song.py \
  "https://tabs.ultimate-guitar.com/tab/crowded-house/weather-with-you-chords-94631" \
  --output weather_with_you.json
```

Import the resulting JSON with the existing Songbook file import flow.

## Provider Configuration

Config precedence is: CLI flag > environment variable > default.

- CLI
  - `--provider` (`ollama|openai|gemini`, default `ollama`)
  - `--model`
  - `--temperature` (default `0.0`)
  - `--max-retries` (default from `SONGBOOK_LLM_MAX_RETRIES`, fallback `3`)
  - `--ollama-base-url` (default `http://localhost:11434`)
  - `--cookie` (raw `Cookie` header value for blocked/authenticated pages)
  - `--cookie-file` (path to a file containing the raw `Cookie` header)
  - `--proxy` (HTTP(S) proxy URL if needed)
  - `--use-selenium` (headless Chrome fetch for JS/bot-protected pages)
  - `--selenium-headed` (show browser window; disables headless, use with `--use-selenium`)
  - `--print-capture` (print extracted text to console before LLM call)
  - `--print-html-snippet` (print first 4000 chars of raw HTML + size for debugging)
  - `--skip-rule-parser` (disable deterministic chord-sheet parser and force LLM extraction)
  - `--text-file` (path to UTF-8 chord/lyrics text; skips HTTP fetch — best when the site blocks capture)
  - `--title` / `--artist` (metadata overrides; `--title` is also the default title for the rule parser)
  - `--verbose` (print whether the rule parser was used or validation failed before LLM fallback)

- Environment
  - `SONGBOOK_LLM_PROVIDER`
  - `SONGBOOK_LLM_MODEL`
  - `SONGBOOK_LLM_TEMPERATURE`
  - `SONGBOOK_LLM_MAX_RETRIES`
  - `OLLAMA_BASE_URL`
  - `OPENAI_API_KEY`
  - `GOOGLE_API_KEY`

Provider defaults:
- Ollama: `llama3.1:8b`
- OpenAI: `gpt-4o-mini`
- Gemini: `gemini-1.5-flash`

## Examples

Ollama:

```bash
python scripts/web_import/import_song.py "<url>" \
  --provider ollama \
  --model llama3.1:8b
```

Ollama (remote base URL, Weather With You):

```bash
python3 scripts/web_import/import_song.py \
  "https://tabs.ultimate-guitar.com/tab/crowded-house/weather-with-you-chords-94631" \
  --provider ollama \
  --model "llama3.2:3b" \
  --ollama-base-url "http://192.168.1.37:40114/olla/ollama" \
  --output "weather-with-you.json"
```

Ollama with browser cookie (for 403-protected pages):

```bash
python3 scripts/web_import/import_song.py \
  "https://tabs.ultimate-guitar.com/tab/crowded-house/weather-with-you-chords-94631" \
  --provider ollama \
  --model "llama3.2:3b" \
  --ollama-base-url "http://192.168.1.37:40114/olla/ollama" \
  --cookie-file "./ug_cookie.txt" \
  --output "weather-with-you.json"
```

`ug_cookie.txt` should contain the exact `Cookie` header value copied from your browser request.

Selenium mode (if user-agent/cookies still fail):

```bash
python3 scripts/web_import/import_song.py \
  "https://tabs.ultimate-guitar.com/tab/crowded-house/weather-with-you-chords-94631" \
  --provider ollama \
  --model "llama3.2:3b" \
  --ollama-base-url "http://192.168.1.37:40114/olla/ollama" \
  --use-selenium \
  --selenium-headed \
  --output "weather-with-you.json"
```

Notes:
- Selenium mode requires Chrome + matching ChromeDriver available on your machine.
- It is slower, but often works better for heavily scripted pages.

OpenAI:

```bash
export OPENAI_API_KEY=...
python scripts/web_import/import_song.py "<url>" \
  --provider openai \
  --model gpt-4o-mini
```

Gemini:

```bash
export GOOGLE_API_KEY=...
python scripts/web_import/import_song.py "<url>" \
  --provider gemini \
  --model gemini-1.5-flash
```

## Validation and Retries

The script validates output in two layers:
- JSON Schema (`songbook_schema.json`)
- Semantic checks (section ordering, phrase ordering, monotonic non-negative chord steps, and a high absolute ceiling on chord `step`)

Default extraction order:
1. Deterministic chord-sheet parser (fast, reliable for `[Section]` + chord/lyric text)
2. LLM extraction + retry (if deterministic parse fails)

If LLM validation fails, the script re-prompts the model with repair feedback up to `--max-retries`.

### If output still looks “empty” (one chord, no lyrics)

Older builds compared chord `step` to **lyric length**. On chord sheets, `step` is the **column on the chord line**, which is often longer than the lyric line — so validation failed, the script fell back to the LLM, and you saw useless JSON again. That check is removed; use `--verbose` to confirm `Used deterministic chord-sheet parser`.

### Import from pasted text (no URL)

Save the chords/lyrics (e.g. from Ultimate Guitar) into `weather.txt`, then:

```bash
python3 scripts/web_import/import_song.py \
  --text-file ./weather.txt \
  --title "Weather With You" \
  --artist "Crowded House" \
  --provider ollama \
  --model "llama3.2:3b" \
  --ollama-base-url "http://192.168.1.37:40114/olla/ollama" \
  --verbose \
  --output weather-with-you.json
```

With `--text-file`, the URL argument is optional (Ollama is still used only if the rule parser does not produce valid JSON).

## Render JSON to performance text

Turn a Songbook JSON file into plain chord/lyric text (same layout intent as `PlainTextSongRenderer` in the app). Section headers are printed as `[Section name]` for quick scanning.

```bash
python3 scripts/web_import/render_song_json.py ./weather-with-you.json
```

Write to a file instead of stdout:

```bash
python3 scripts/web_import/render_song_json.py ./weather-with-you.json -o ./weather-with-you.txt
```

## Run Tests

```bash
pytest scripts/web_import/tests -q
```
