//
//  ChordOrderingTests.swift
//  SongbookTests
//
//  Created by John Haselden on 04/01/2026.
//

import Foundation
import Testing
@testable import Songbook

struct ChordOrderingTests {

    @Test func chordOrderingTest() async throws {
        let aMajor = Chord(id: UUID(), rootNote: .A)
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        let a7Sus2 = Chord(id: UUID(), rootNote: .A, chordType: .seventh, seventhType: .dominant, suspendedType: .second)
        
        let cMajor = Chord(id: UUID(), rootNote: .C)
        
        let dMajor = Chord(id: UUID(), rootNote: .D)
        let dMajorSus2 = Chord(id: UUID(), rootNote: .D, suspendedType: .second)
        let dMajorSus4 = Chord(id: UUID(), rootNote: .D, suspendedType: .fourth)

        #expect(aMinor < cMajor)
        #expect(aMajor < cMajor)
        #expect(aMajor < aMinor)
        #expect(aMinor < a7Sus2)
        
        #expect(cMajor < dMajor)
        #expect(dMajor < dMajorSus2)
        #expect(dMajorSus2 < dMajorSus4)
    }

}
