import Testing
@testable import Songbook

struct ChordTokenParserTests {
    @Test func parsesEm7() async throws {
        let chord = ChordTokenParser.parse("Em7")
        #expect(chord != nil)
        #expect(chord?.rootNote == .E)
        #expect(chord?.rootNoteAlteration == .natural)
        #expect(chord?.chordType == .seventh)
        #expect(chord?.seventhType == .minor)
    }
    
    @Test func parsesAsus4() async throws {
        let chord = ChordTokenParser.parse("Asus4")
        #expect(chord != nil)
        #expect(chord?.rootNote == .A)
        #expect(chord?.rootNoteAlteration == .natural)
        #expect(chord?.chordType == .major)
        #expect(chord?.suspendedType == .fourth)
        #expect(chord?.seventhType == nil)
    }
    
    @Test func parsesA7sus4() async throws {
        let chord = ChordTokenParser.parse("A7sus4")
        #expect(chord != nil)
        #expect(chord?.rootNote == .A)
        #expect(chord?.chordType == .seventh)
        #expect(chord?.seventhType == .dominant)
        #expect(chord?.suspendedType == .fourth)
    }
    
    @Test func parsesSlashBassSharp() async throws {
        let chord = ChordTokenParser.parse("D/F#")
        #expect(chord != nil)
        #expect(chord?.rootNote == .D)
        #expect(chord?.chordType == .major)
        #expect(chord?.bassNote == .F)
        #expect(chord?.bassNoteAlteration == .sharp)
    }
}

