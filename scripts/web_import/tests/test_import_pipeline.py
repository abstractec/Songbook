import json
import uuid
from pathlib import Path

from scripts.web_import.import_song import (
    parse_chord_sheet_text,
    postprocess_song,
    strip_leading_underscore_keys,
    validate_semantics,
    validate_song,
)


def _sample_song():
    return {
        "id": str(uuid.uuid4()),
        "title": "Weather With You",
        "artist": "Crowded House",
        "sections": [
            {
                "id": str(uuid.uuid4()),
                "name": "Verse 1",
                "position": 0,
                "phrases": [
                    {
                        "id": str(uuid.uuid4()),
                        "position": 0,
                        "repeats": 1,
                        "lyric": {"id": str(uuid.uuid4()), "text": "Everywhere you go"},
                        "chordSequence": {
                            "id": str(uuid.uuid4()),
                            "sequence": [
                                {
                                    "id": str(uuid.uuid4()),
                                    "step": 0,
                                    "chord": {
                                        "id": str(uuid.uuid4()),
                                        "root_note": "D",
                                        "root_note_alteration": "natural",
                                        "chord_type": "major",
                                        "seventh_type": None,
                                        "extended_type": None,
                                        "suspended_type": None,
                                        "added_type": None,
                                        "added_alteration": "natural",
                                        "bass_note": None,
                                        "bass_note_alteration": None,
                                        "image_path": None,
                                    },
                                },
                                {
                                    "id": str(uuid.uuid4()),
                                    "step": 10,
                                    "chord": {
                                        "id": str(uuid.uuid4()),
                                        "root_note": "A",
                                        "root_note_alteration": "natural",
                                        "chord_type": "major",
                                        "seventh_type": None,
                                        "extended_type": None,
                                        "suspended_type": None,
                                        "added_type": None,
                                        "added_alteration": "natural",
                                        "bass_note": None,
                                        "bass_note_alteration": None,
                                        "image_path": None,
                                    },
                                },
                            ],
                        },
                    }
                ],
            }
        ],
    }


def test_postprocess_reorders_and_normalizes():
    song = _sample_song()
    phrase = song["sections"][0]["phrases"][0]
    phrase["chordSequence"]["sequence"] = list(reversed(phrase["chordSequence"]["sequence"]))
    phrase["repeats"] = 0

    processed = postprocess_song(song)
    steps = [s["step"] for s in processed["sections"][0]["phrases"][0]["chordSequence"]["sequence"]]

    assert steps == [0, 10]
    assert processed["sections"][0]["phrases"][0]["repeats"] == 1
    assert processed["sections"][0]["position"] == 0
    assert processed["sections"][0]["phrases"][0]["position"] == 0


def test_semantic_validator_flags_extreme_chord_steps():
    song = _sample_song()
    song["sections"][0]["phrases"][0]["chordSequence"]["sequence"][1]["step"] = 5000

    errors = validate_semantics(song)
    assert any("exceeds absolute limit" in err for err in errors)


def test_schema_validation_passes_fixture():
    schema_path = Path(__file__).resolve().parents[1] / "songbook_schema.json"
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    song = _sample_song()

    errors = validate_song(song, schema)
    assert errors == []


def test_postprocess_accepts_list_chord_sequence_shape():
    song = _sample_song()
    phrase = song["sections"][0]["phrases"][0]
    phrase["chordSequence"] = phrase["chordSequence"]["sequence"]

    processed = postprocess_song(song)
    normalized = processed["sections"][0]["phrases"][0]["chordSequence"]

    assert isinstance(normalized, dict)
    assert "id" in normalized
    assert isinstance(normalized["sequence"], list)


def test_postprocess_normalizes_null_required_chord_fields():
    song = _sample_song()
    step = song["sections"][0]["phrases"][0]["chordSequence"]["sequence"][0]
    step["chord"]["root_note"] = None
    step["chord"]["root_note_alteration"] = None
    step["chord"]["chord_type"] = None
    step["chord"]["added_alteration"] = None

    processed = postprocess_song(song)
    chord = processed["sections"][0]["phrases"][0]["chordSequence"]["sequence"][0]["chord"]

    assert chord["root_note"] == "C"
    assert chord["root_note_alteration"] == "natural"
    assert chord["chord_type"] == "major"
    assert chord["added_alteration"] == "natural"


def test_strip_leading_underscore_keys():
    raw = {"-id": "x", "id": "550e8400-e29b-41d4-a716-446655440000", "title": "T"}
    cleaned = strip_leading_underscore_keys(raw)
    assert "-id" not in cleaned
    assert cleaned["id"] == "550e8400-e29b-41d4-a716-446655440000"


def test_rule_parser_long_chord_row_short_lyric_passes_semantics():
    schema_path = Path(__file__).resolve().parents[1] / "songbook_schema.json"
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    text = """[Verse]
| Em7 | A Asus4 A | Em7 | Asus4 A A | Em7 | A Asus4 A | Em7 |
Walking 'round the room,
"""
    song = parse_chord_sheet_text(text, fallback_title="T")
    processed = postprocess_song(song)
    errors = validate_song(processed, schema)
    assert errors == []


def test_rule_parser_extracts_sections_and_phrases():
    text = """
[Intro]
| Em7 | A Asus4 A | Em7 |

[Verse]
A Asus4 A | Em7 | A Asus4
Walking 'round the room singing stormy weather,
"""
    song = parse_chord_sheet_text(text, fallback_title="Weather With You")
    assert song is not None
    assert len(song["sections"]) == 2
    assert song["sections"][0]["name"] == "Intro"
    assert song["sections"][1]["name"] == "Verse"
    verse_phrase = song["sections"][1]["phrases"][0]
    assert verse_phrase["lyric"]["text"].startswith("Walking 'round")
    assert len(verse_phrase["chordSequence"]["sequence"]) >= 3
