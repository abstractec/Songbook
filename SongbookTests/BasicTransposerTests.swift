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
        
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let a7Sus2 = Chord(id: UUID(), rootNote: .A, chordType: .seventh, seventhType: .dominant, suspendedType: .second)

        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: a7Sus2, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMinor, step: 2)
        ])

        let lyric1 = Lyric(id: UUID(), text: "I want to make this work")
        let phrase1 = Phrase(id: UUID(), sections: [], lyric: lyric1, chordSequence: introSequence)
        
        let newPhrase = transposer.transpose(phrase: phrase1, by: 2) // A should go to B in this instance
        let chordRenderer = PlainTextChordRenderer()
        
        // what we're expecting here is a B Major 7 suspended 2nd and a B minor
        print("newPhrase: ")
        
        for step in newPhrase.chordSequence.sequence {
            print("\t \(chordRenderer.renderShortName(chord: step.chord))")
        }
        
        let renderer = PlainTextSongRenderer()
        let text = renderer.render(phrase: newPhrase)
        
        print(text)
    }
    
    @Test func testADown2Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: -2)
        
        #expect(transposedNote?.0 == Note.G)
        #expect(transposedNote?.1 == .natural)
    }

    @Test func testAUp2Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: 2)
        
        #expect(transposedNote?.0 == Note.B)
        #expect(transposedNote?.1 == .natural)
    }

    @Test func testASharpUp2Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .sharp, steps: 2)
        
        #expect(transposedNote?.0 == Note.C)
        #expect(transposedNote?.1 == .natural)
    }

    @Test func testCSharpUp2Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .C
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .sharp, steps: 2)
        
        #expect(transposedNote?.0 == Note.D)
        #expect(transposedNote?.1 == .sharp)
    }

    @Test func testADown12Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: -12)
        
        #expect(transposedNote?.0 == Note.A)
        #expect(transposedNote?.1 == .natural)
    }

    @Test func testAUp12Semitones() async throws {
        let transposer = BasicTransposer()
        
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: 12)
        
        #expect(transposedNote?.0 == Note.A)
        #expect(transposedNote?.1 == .natural)
    }
    
    @Test func testASharpBFlat() async throws {
        let transposer = BasicTransposer()
        let note: Note = .A
        let transposedNote: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: 1, preferFlats: true)
        
        #expect(transposedNote?.0 == Note.B)
        #expect(transposedNote?.1 == .flat)
        
        let transposedNote2: (Note, Alteration)? = transposer.noteTransposer(note, alteration: .natural, steps: 1, preferFlats: false)
        
        #expect(transposedNote2?.0 == Note.A)
        #expect(transposedNote2?.1 == .sharp)
        
    }

    

}
