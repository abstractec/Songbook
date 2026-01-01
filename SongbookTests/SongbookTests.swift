//
//  SongbookTests.swift
//  SongbookTests
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import Testing
@testable import Songbook
import uuid
import XCTest

struct SongbookTests {
    @Test func testSong() async throws {
        let cMinor = Chord(id: UUID(), name: "C Minor", shortName: "Cm" , imagePath: nil)
        let aMajor = Chord(id: UUID(), name: "A Major", shortName: "A" , imagePath: nil)
        let dMajor = Chord(id: UUID(), name: "D Major", shortName: "D" , imagePath: nil)
        
        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 10)

        ])

        let introSequencePhrase = Phrase(id: UUID(), sections: [], lyric: nil, chordSequence: introSequence, chordSequenceRepeatCount: 4)
        

        let lyric1 = Lyric(id: UUID(), text: "This is a test lyric")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)
        
        let chordSequence2 = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 5),
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 12),
            ChordSequenceStep(id: UUID(), chord: dMajor, step: 19),
        ])

        let lyric2 = Lyric(id: UUID(), text: "This is the second line of a test lyric")
        let phrase2 = Phrase(id: UUID(), sections: [], lyric: lyric2, chordSequence: chordSequence2)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "C Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [introSequencePhrase, phrase1, phrase2])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        
        
        let expected = """
Test Song
---------
Key: C Major
Capo: 2nd fret

Verse 1

Cm        A  x 4

Cm        A
This is a test lyric
Cm   A      Cm     D
This is the second line of a test lyric
"""
        
        XCTAssertEqual(renderer.render(song: song), expected, "Rendered text does not match expected")
    
    }


    @Test func testLargeChord() async throws {
        let expected = """
Test Song
---------
Key: A Major
Capo: 2nd fret

Verse 1

A7sus2 A                     
I      want to make this work

"""
        let aMajor = Chord(id: UUID(), name: "A Major", shortName: "A" , imagePath: nil)
        let a7Sus2 = Chord(id: UUID(), name: "A Major 7 suspended 2nd", shortName: "A7sus2", imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 2),
            ChordSequenceStep(id: UUID(), chord: a7Sus2, step: 0)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "A Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase1])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        let rendered = renderer.render(song: song)
        
        #expect(expected == rendered)
        

    }

    @Test func testLargeChordTrailing() async throws {
        let expected = """
Test Song
---------
Key: A Major
Capo: 2nd fret

Verse 1

A                   A7sus2   
I want to make this work

"""
        let aMajor = Chord(id: UUID(), name: "A Major", shortName: "A" , imagePath: nil)
        let a7Sus2 = Chord(id: UUID(), name: "A Major 7 suspended 2nd", shortName: "A7sus2" , imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 0),
            ChordSequenceStep(id: UUID(), chord: a7Sus2, step: 20)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "A Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase1])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        let rendered = renderer.render(song: song)
        
        #expect(expected == rendered)
        

    }
    
    @Test func testTwoCharChords() async throws {
        let expected = """
Test Song
---------
Key: A Major
Capo: 2nd fret

Verse 1

Am        D             
I want to make this work

"""
        let aMinor = Chord(id: UUID(), name: "A Minor", shortName: "Am" , imagePath: nil)
        let dMajor = Chord(id: UUID(), name: "D Major", shortName: "D" , imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: aMinor, step: 0),
            ChordSequenceStep(id: UUID(), chord: dMajor, step: 10)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "A Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase1])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        let rendered = renderer.render(song: song)
        
        #expect(expected == rendered)
        

    }
    
    @Test func testBigChordAndTwoCharChords() async throws {
        let expected = """
Test Song
---------
Key: A Major
Capo: 2nd fret

Verse 1

A7sus2 Am                     
I      want to make this work

"""
        let a7Sus2 = Chord(id: UUID(), name: "A Major 7 suspended 2nd", shortName: "A7sus2", imagePath: nil)
        let aMinor = Chord(id: UUID(), name: "A Minor", shortName: "Am" , imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: a7Sus2, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMinor, step: 2)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "A Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase1])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        let rendered = renderer.render(song: song)
        
        #expect(expected == rendered)
    }
}
