//
//  PlainTextPhraseRendererTests.swift
//  SongbookTests
//
//  Created by John Haselden on 05/01/2026.
//

import Foundation
import Testing
@testable import Songbook

struct PlainTextPhraseRendererTests {

    @Test func testPhraseRenderWithNoRepeat() async throws {
        let expected = """
Am               C             
This should be a line of lyrics
"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(phrase: phrase)
        
        #expect(expected == rendered)
    }

    @Test func testPhraseRenderWithDoubleRepeat() async throws {
        let expected = """
Am               C              x2
This should be a line of lyrics
"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1, repeats: 2)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(phrase: phrase)
        
        #expect(expected == rendered)
    }
    
    @Test func testSection() async throws {
        let expected = """
Verse 1

Am               C             
This should be a line of lyrics

"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)
        let song = Song(id: UUID(), title: "Song 1", sections: [])
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
        song.sections.append(section)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(section: section)
        
        #expect(expected == rendered)
    }

    @Test func testSectionWithRepeat() async throws {
        let expected = """
Verse 1

Am               C              x2
This should be a line of lyrics

"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1, repeats: 2)
        let song = Song(id: UUID(), title: "Song 1", sections: [])
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
        song.sections.append(section)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(section: section)
        
        #expect(expected == rendered)
    }

    @Test func testSong() async throws {
        let expected = """
Song 1
------
Verse 1

Am               C             
This should be a line of lyrics

"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)
        let song = Song(id: UUID(), title: "Song 1", sections: [])
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
        song.sections.append(section)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(song: song)
        
        #expect(expected == rendered)
    }

    @Test func testSongWithRepeat() async throws {
        let expected = """
Song 1
------
Verse 1

Am               C              x2
This should be a line of lyrics

"""
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let cMajor = Chord(id: UUID(), rootNote: .C)

        let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
        let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

        let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

        let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
        let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1, repeats: 2)
        let song = Song(id: UUID(), title: "Song 1", sections: [])
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
        song.sections.append(section)

        let songRenderer = PlainTextSongRenderer()
        let rendered = songRenderer.render(song: song)
        
        #expect(expected == rendered)
    }
}
