#!/usr/bin/env python3
"""
Print Songbook song JSON as plain chord/lyric text for performance
(same layout intent as PlainTextSongRenderer in the app).
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from .performance_render import render_song, load_song_json
except ImportError:
    from performance_render import render_song, load_song_json


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Render Songbook JSON to plain performance text (chords + lyrics)."
    )
    parser.add_argument(
        "json_path",
        type=Path,
        help="Path to song JSON (same shape as app export / import).",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Write to file instead of stdout (UTF-8).",
    )
    args = parser.parse_args()

    if not args.json_path.is_file():
        print(f"Not a file: {args.json_path}", file=sys.stderr)
        sys.exit(1)

    song = load_song_json(args.json_path)
    text = render_song(song)

    if args.output is not None:
        args.output.write_text(text, encoding="utf-8")
        print(f"Wrote {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
