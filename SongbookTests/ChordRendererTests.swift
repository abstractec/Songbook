//
//  ChordRendererTests.swift
//  SongbookTests
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import Testing
@testable import Songbook

struct ChordRendererTests {

    @Test func testAMinor() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        
        // I'm expecting
        #expect(chordRenderer.renderShortName(chord: chord) == "Am")
        #expect(chordRenderer.render(chord: chord) == "A minor")
    }

    @Test func testA7Sus4() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), rootNote: .A, chordType: .seventh, seventhType: .major, suspendedType: .fourth)
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)

        // I'm expecting
        #expect(shortName == "Amaj7sus4")
        #expect(longName == "A major 7th suspended fourth")
    }
    
    @Test func testDMajorWithFSharpBass() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), rootNote: .D, bassNote: .F, bassNoteAlteration: .sharp)
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)

        // I'm expecting
        #expect(shortName == "D/F#")
        #expect(longName == "D major with F# bass")

    }
    
    @Test func testPurpleChord() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), rootNote: .E, chordType: .seventh, seventhType: .dominant, addedType: .ninth, addedAlteration: .sharp)
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)
        
        #expect(shortName == "E7#9")
        #expect(longName == "E dominant 7th sharp 9")
    }

}
