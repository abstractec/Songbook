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
        
        let chord = Chord(id: UUID(), root: .A, chordType: .minor)
        
        // I'm expecting
        #expect(chordRenderer.renderShortName(chord: chord) == "Am")
        #expect(chordRenderer.render(chord: chord) == "A minor")
    }

    @Test func testA7Sus4() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), root: .A, chordType: .seventh, seventhType: .major, suspendedType: .fourth)
////        let chord = Chord(id: UUID(), name: "A major 7 suspended fourth", shortName: "A7sus4", imagePath: nil)
//        chord.root = "A"
//        chord.chordType = ChordType.major
//        chord.suspended = true
//        chord.suspendedBy = 4
//        chord.altered = true
//        chord.alteration = 7
        
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)

        // I'm expecting
        #expect(shortName == "Amaj7sus4")
        #expect(longName == "A major 7th suspended fourth")
    }
    
    @Test func testDMajorWithFSharpBass() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), root: .D, bassNote: .F, bassNoteAlteration: .sharp)
//        let chord = Chord(id: UUID(), name: "D major with F# bass", shortName: "D/F#", imagePath: nil)
//        chord.root = "D"
//        chord.chordType = ChordType.major
//        chord.suspended = false
//        chord.altered = false
//        chord.bassNote = "F#"
//        
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)

        // I'm expecting
        #expect(shortName == "D/F#")
        #expect(longName == "D major with F# bass")

    }
    
    @Test func testPurpleChord() async throws {
        let chordRenderer = PlainTextChordRenderer()
        
        let chord = Chord(id: UUID(), root: .E, chordType: .seventh, seventhType: .dominant, addedType: .ninth, addedAlteration: .sharp)
        
//        chord.root = "E"
//        chord.chordType = ChordType.seventh
//        chord.addedType = .ninth
//        chord.addedAlteration = .sharp
       
        let shortName = chordRenderer.renderShortName(chord: chord)
        let longName = chordRenderer.render(chord: chord)
        
        #expect(shortName == "E7#9")
        #expect(longName == "E dominant 7th sharp 9")
    }

}
