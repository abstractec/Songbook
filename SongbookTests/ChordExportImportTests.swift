//
//  ChordExportImportTests.swift
//  Songbook
//
//  Created by John Haselden on 04/01/2026.
//

import Foundation
import Testing
@testable import Songbook

struct ChordExportImportTests {
    
    @Test func testAMinorExport() async throws {
        let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode([aMinor])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
                // TODO: need a better test
            }
        } catch {
            print("Failed to encode model: \(error.localizedDescription)")
            #expect(Bool(false), "decoding error")
        }
    }
    
    
    @Test func testAMinorImport() async throws {
        let jsonString = """
            [
              {
                "bass_note" : null,
                "added_alteration" : "natural",
                "bass_note_alteration" : null,
                "id" : "FCB904D5-40C1-4CA0-A975-D01124329595",
                "chord_type" : "minor",
                "added_type" : null,
                "root_note_alteration" : "natural",
                "extended_type" : null,
                "root_note" : "A",
                "suspended_type" : null,
                "seventh_type" : null
              }
            ]            
            """
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let chords = try JSONDecoder().decode([Chord].self, from: jsonData)
            
            var found = false
            
            for chord in chords {
                if chord.rootNote == .A && chord.chordType == .minor && chord.seventhType == nil {
                    found = true
                }
            }

            #expect(found, "We Should have decoded A Minor")
        } catch {
            print("Decoding error: \(error)")
            #expect(Bool(false), "JSON Error")
        }

    }
    
    /**
     This function is here to export a bunch of minor chords so that you don't have to enter them all yourself
     */
    @Test func exportMajorChords() async throws {
        var chords: [Chord] = []
        
        for note in allNotes {
            chords.append(self.buildMajorChord(note.0, alteration: note.1))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(chords)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Failed to encode model: \(error.localizedDescription)")
            #expect(Bool(false), "decoding error")
        }
    }
    
    @Test func exportMinorChords() async throws {
        var chords: [Chord] = []
        
        for note in allNotes {
            chords.append(self.buildMinorChord(note.0, alteration: note.1))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(chords)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Failed to encode model: \(error.localizedDescription)")
            #expect(Bool(false), "decoding error")
        }
    }
    
    @Test func exportAllChords() async throws {
        var chords: [Chord] = []
        
        for note in allNotes {
            chords.append(self.buildMajorChord(note.0, alteration: note.1))
            chords.append(self.buildMinorChord(note.0, alteration: note.1))
            chords.append(self.buildMajorSeventhChord(note.0, alteration: note.1))
            chords.append(self.buildMinorSeventhChord(note.0, alteration: note.1))
            chords.append(self.buildDominantSeventhChord(note.0, alteration: note.1))
            chords.append(self.buildHalfDiminisedSeventhChord(note.0, alteration: note.1))
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(chords)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Failed to encode model: \(error.localizedDescription)")
            #expect(Bool(false), "decoding error")
        }

    }
    
    private func buildMinorChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration, chordType: .minor)
    }

    private func buildMajorChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration)
    }

    private func buildMajorSeventhChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration, chordType: .seventh, seventhType: .major)
    }

    private func buildMinorSeventhChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration, chordType: .seventh, seventhType: .minor)
    }

    private func buildDominantSeventhChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration, chordType: .seventh, seventhType: .dominant)
    }

    private func buildHalfDiminisedSeventhChord(_ rootNote: Note, alteration: Alteration = .natural) -> Chord {
        return Chord(id: UUID(), rootNote: rootNote, rootNoteAlteration: alteration, chordType: .seventh, seventhType: .halfDimished)
    }

    private var allNotes: [(Note, Alteration)] {
        let notes = [
            (Note.A, Alteration.natural),
            (Note.A, Alteration.sharp),
            (Note.B, Alteration.natural),
            (Note.C, Alteration.natural),
            (Note.C, Alteration.sharp),
            (Note.D, Alteration.natural),
            (Note.D, Alteration.sharp),
            (Note.E, Alteration.natural),
            (Note.F, Alteration.natural),
            (Note.F, Alteration.sharp),
            (Note.G, Alteration.natural),
            (Note.G, Alteration.sharp),
        ]
        
        return notes
    }
}
