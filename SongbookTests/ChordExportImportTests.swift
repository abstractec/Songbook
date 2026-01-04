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
        encoder.outputFormatting = .prettyPrinted // Optional: for readable JSON

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

}
