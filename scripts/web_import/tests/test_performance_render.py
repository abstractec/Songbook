from scripts.web_import.performance_render import render_phrase, render_section, render_song


def test_phrase_render_matches_app_plaintext_fixture():
    phrase = {
        "lyric": {"text": "This should be a line of lyrics"},
        "repeats": 1,
        "chordSequence": {
            "sequence": [
                {
                    "step": 0,
                    "chord": {
                        "root_note": "A",
                        "root_note_alteration": "natural",
                        "chord_type": "minor",
                        "seventh_type": None,
                        "extended_type": None,
                        "suspended_type": None,
                        "added_type": None,
                        "added_alteration": "natural",
                        "bass_note": None,
                        "bass_note_alteration": None,
                    },
                },
                {
                    "step": 17,
                    "chord": {
                        "root_note": "C",
                        "root_note_alteration": "natural",
                        "chord_type": "major",
                        "seventh_type": None,
                        "extended_type": None,
                        "suspended_type": None,
                        "added_type": None,
                        "added_alteration": "natural",
                        "bass_note": None,
                        "bass_note_alteration": None,
                    },
                },
            ]
        },
    }
    # PlainTextSongRenderer.render(phrase:) — no trailing newline on lyric line.
    expected = (
        "Am               C             \n"
        "This should be a line of lyrics"
    )
    assert render_phrase(phrase) == expected


def test_phrase_with_repeats():
    phrase = {
        "lyric": {"text": "This should be a line of lyrics"},
        "repeats": 2,
        "chordSequence": {
            "sequence": [
                {
                    "step": 0,
                    "chord": {
                        "root_note": "A",
                        "root_note_alteration": "natural",
                        "chord_type": "minor",
                        "seventh_type": None,
                        "extended_type": None,
                        "suspended_type": None,
                        "added_type": None,
                        "added_alteration": "natural",
                        "bass_note": None,
                        "bass_note_alteration": None,
                    },
                },
                {
                    "step": 17,
                    "chord": {
                        "root_note": "C",
                        "root_note_alteration": "natural",
                        "chord_type": "major",
                        "seventh_type": None,
                        "extended_type": None,
                        "suspended_type": None,
                        "added_type": None,
                        "added_alteration": "natural",
                        "bass_note": None,
                        "bass_note_alteration": None,
                    },
                },
            ]
        },
    }
    expected = (
        "Am               C              x2\n"
        "This should be a line of lyrics"
    )
    assert render_phrase(phrase) == expected


def test_render_song_matches_app_plaintext_song_fixture():
    song = {
        "title": "Song 1",
        "sections": [
            {
                "name": "Verse 1",
                "position": 0,
                "phrases": [
                    {
                        "position": 0,
                        "repeats": 1,
                        "lyric": {"text": "This should be a line of lyrics"},
                        "chordSequence": {
                            "sequence": [
                                {
                                    "step": 0,
                                    "chord": {
                                        "root_note": "A",
                                        "root_note_alteration": "natural",
                                        "chord_type": "minor",
                                        "seventh_type": None,
                                        "extended_type": None,
                                        "suspended_type": None,
                                        "added_type": None,
                                        "added_alteration": "natural",
                                        "bass_note": None,
                                        "bass_note_alteration": None,
                                    },
                                },
                                {
                                    "step": 17,
                                    "chord": {
                                        "root_note": "C",
                                        "root_note_alteration": "natural",
                                        "chord_type": "major",
                                        "seventh_type": None,
                                        "extended_type": None,
                                        "suspended_type": None,
                                        "added_type": None,
                                        "added_alteration": "natural",
                                        "bass_note": None,
                                        "bass_note_alteration": None,
                                    },
                                },
                            ]
                        },
                    }
                ],
            }
        ],
    }
    expected = """Song 1
------
[Verse 1]

Am               C             
This should be a line of lyrics

"""
    assert render_song(song) == expected
