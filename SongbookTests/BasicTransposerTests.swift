//
//  BasicTransposerTests.swift
//  SongbookTests
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import Testing
@testable import Songbook

struct BasicTransposerTests {

    @Test func testPhraseTransposition() async throws {
        let transposer = BasicTransposer()
        
        let a7Sus2 = Chord(id: UUID(), name: "A Major 7 suspended 2nd", shortName: "A7sus2", imagePath: nil)
        let aMinor = Chord(id: UUID(), name: "A Minor", shortName: "Am" , imagePath: nil)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: a7Sus2, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMinor, step: 2)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)
        
        let newPhrase = transposer.transpose(phrase: phrase1, by: 2) // A should go to B in this instance
        
        // what we're expecting here is a B Major 7 suspended 2nd and a B minor
        print("newPhrase: ")
        
        for chords in newPhrase.chordSequence.sequence {
            print("\t \(chords.chord.shortName)")
        }
        
        let renderer = PlainTextSongRenderer()
        let text = renderer.render(phrase: newPhrase)
        
        print(text)
    }

}
