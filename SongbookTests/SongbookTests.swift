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

struct SongbookTests {
    @Test func testSong() async throws {
        let cMinor = Chord(id: UUID(), name: "C Minor", shortName: "Cm" , imagePath: nil)
        let aMajor = Chord(id: UUID(), name: "A Major", shortName: "A" , imagePath: nil)
        let dMajor = Chord(id: UUID(), name: "D Major", shortName: "D" , imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), chords: [cMinor, aMajor], spacing: [0, 10])
        let introSequencePhrase = Phrase(id: UUID(), sections: [], lyric: nil, chordSequence: introSequence, chordSequenceRepeatCount: 4)

        let chordSequence1 = ChordSequence(id: UUID(), chords: [cMinor, aMajor], spacing: [0, 10])
        let lyric1 = Lyric(id: UUID(), text: "This is a test lyric")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: chordSequence1)

        let chordSequence2 = ChordSequence(id: UUID(), chords: [cMinor, aMajor, cMinor, dMajor], spacing: [0, 5, 12, 19])
        let lyric2 = Lyric(id: UUID(), text: "This is the second line of a test lyric")
        let phrase2 = Phrase(id: UUID(), sections: [], lyric: lyric2, chordSequence: chordSequence2)

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "C Major", capo: 2)
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [introSequencePhrase, phrase1, phrase2])
        
        song.sections.append(section)
        
        let renderer = PlainTextSongRenderer()
        print (renderer.render(song: song))
    
    }


}
