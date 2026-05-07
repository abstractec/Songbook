//
//  SongImportExportTests.swift
//  SongbookTests
//
//  Created by John Haselden on 16/01/2026.
//

import Foundation
import Testing
@testable import Songbook
import uuid

struct SongImportExportTests {

    @Test func testSongExport() async throws {
        let cMinor = Chord(id: UUID(), rootNote: .C, chordType: .minor)
        let aMajor = Chord(id: UUID(), rootNote: .A)
        let dMajor = Chord(id: UUID(), rootNote: .D)
        
        let introSequence = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 10)

        ])

        let introSequencePhrase = Phrase(id: UUID(), chordSequence: introSequence, position: 0, repeats: 1)
        

        let lyric1 = Lyric(id: UUID(), text: "This is a test lyric")
        let phrase1 = Phrase(id: UUID(), chordSequence: introSequence, position: 0, repeats: 1)
        phrase1.lyric = lyric1
        
        let chordSequence2 = ChordSequence(id: UUID(), sequence: [
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 0),
            ChordSequenceStep(id: UUID(), chord: aMajor, step: 5),
            ChordSequenceStep(id: UUID(), chord: cMinor, step: 12),
            ChordSequenceStep(id: UUID(), chord: dMajor, step: 19),
        ])

        let lyric2 = Lyric(id: UUID(), text: "This is the second line of a test lyric")
        let phrase2 = Phrase(id: UUID(), chordSequence: chordSequence2, position: 0, repeats: 1)
        phrase2.lyric = lyric2

        let song = Song(id: UUID(), title: "Test Song", sections: [], key: "C Major")
        let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [introSequencePhrase, phrase1, phrase2])
        
        song.sections.append(section)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(song)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                
                // TODO: need a better test
            }
        } catch {
            print("Failed to encode model: \(error.localizedDescription)")
            #expect(Bool(false), "decoding error")
        }
    }

    @Test func testSongImport() async throws {
        
        let jsonString = """
            {
              "sections" : [
                {
                  "id" : "721BBE45-CFC1-4902-8E88-47C883A9365A",
                  "phrases" : [
                    {
                      "lyric" : {
                        "id" : "A90880BD-27E4-409A-871F-3E7DF1740517",
                        "text" : ""
                      },
                      "id" : "0A4558B2-4E5E-424E-9A57-66D91FF58CE7",
                      "position" : 0,
                      "repeats" : 1,
                      "chordSequence" : {
                        "sequence" : [
                          {
                            "step" : 0,
                            "chord" : {
                              "root_note_alteration" : "natural",
                              "extended_type" : null,
                              "chord_type" : "minor",
                              "added_alteration" : "natural",
                              "bass_note_alteration" : null,
                              "id" : "0C15507A-9C34-4278-A45C-74E356149602",
                              "bass_note" : null,
                              "suspended_type" : null,
                              "root_note" : "C",
                              "added_type" : null,
                              "seventh_type" : null
                            },
                            "id" : "852D8102-ADEC-45C1-B10F-281CA20BE2F7"
                          },
                          {
                            "step" : 10,
                            "chord" : {
                              "bass_note_alteration" : null,
                              "added_alteration" : "natural",
                              "added_type" : null,
                              "suspended_type" : null,
                              "bass_note" : null,
                              "root_note_alteration" : "natural",
                              "root_note" : "A",
                              "seventh_type" : null,
                              "extended_type" : null,
                              "chord_type" : "major",
                              "id" : "FA05D789-8300-4C90-A760-11E3407B18E7"
                            },
                            "id" : "D2722264-5CB8-454B-90C3-E6AFCFD614D1"
                          }
                        ],
                        "id" : "532529C5-AC8B-4169-9F2C-2C8A4081982B"
                      }
                    },
                    {
                      "lyric" : {
                        "text" : "This is a test lyric",
                        "id" : "9CE0D74E-A8F2-40BF-9F81-4B4EE94CADAC"
                      },
                      "id" : "B29BFC5D-0E52-4DDA-BB39-6264DC734ECB",
                      "position" : 0,
                      "repeats" : 1,
                      "chordSequence" : {
                        "sequence" : [
                          {
                            "id" : "852D8102-ADEC-45C1-B10F-281CA20BE2F7",
                            "step" : 0,
                            "chord" : {
                              "added_type" : null,
                              "extended_type" : null,
                              "seventh_type" : null,
                              "chord_type" : "minor",
                              "root_note" : "C",
                              "root_note_alteration" : "natural",
                              "id" : "0C15507A-9C34-4278-A45C-74E356149602",
                              "suspended_type" : null,
                              "added_alteration" : "natural",
                              "bass_note_alteration" : null,
                              "bass_note" : null
                            }
                          },
                          {
                            "id" : "D2722264-5CB8-454B-90C3-E6AFCFD614D1",
                            "step" : 10,
                            "chord" : {
                              "seventh_type" : null,
                              "chord_type" : "major",
                              "bass_note" : null,
                              "extended_type" : null,
                              "bass_note_alteration" : null,
                              "suspended_type" : null,
                              "root_note_alteration" : "natural",
                              "id" : "FA05D789-8300-4C90-A760-11E3407B18E7",
                              "root_note" : "A",
                              "added_type" : null,
                              "added_alteration" : "natural"
                            }
                          }
                        ],
                        "id" : "532529C5-AC8B-4169-9F2C-2C8A4081982B"
                      }
                    },
                    {
                      "lyric" : {
                        "text" : "This is the second line of a test lyric",
                        "id" : "C557B5D4-A576-474C-8D7E-6744F6D6E467"
                      },
                      "id" : "93907EDA-A44E-45B4-9F53-A98F7D967BDC",
                      "position" : 0,
                      "repeats" : 1,
                      "chordSequence" : {
                        "sequence" : [
                          {
                            "id" : "7DD9FA05-ED11-4CE9-B959-E8FE9410ACD1",
                            "step" : 0,
                            "chord" : {
                              "root_note_alteration" : "natural",
                              "root_note" : "C",
                              "bass_note" : null,
                              "chord_type" : "minor",
                              "added_type" : null,
                              "added_alteration" : "natural",
                              "extended_type" : null,
                              "suspended_type" : null,
                              "id" : "0C15507A-9C34-4278-A45C-74E356149602",
                              "bass_note_alteration" : null,
                              "seventh_type" : null
                            }
                          },
                          {
                            "id" : "378925EA-FF30-4239-AEAF-41D1B14CA09A",
                            "step" : 5,
                            "chord" : {
                              "seventh_type" : null,
                              "chord_type" : "major",
                              "root_note" : "A",
                              "added_alteration" : "natural",
                              "bass_note_alteration" : null,
                              "root_note_alteration" : "natural",
                              "id" : "FA05D789-8300-4C90-A760-11E3407B18E7",
                              "added_type" : null,
                              "extended_type" : null,
                              "suspended_type" : null,
                              "bass_note" : null
                            }
                          },
                          {
                            "id" : "7D2E1683-E2CC-46F1-B097-67FC5EE05A36",
                            "step" : 12,
                            "chord" : {
                              "id" : "0C15507A-9C34-4278-A45C-74E356149602",
                              "seventh_type" : null,
                              "root_note" : "C",
                              "extended_type" : null,
                              "suspended_type" : null,
                              "chord_type" : "minor",
                              "bass_note_alteration" : null,
                              "bass_note" : null,
                              "root_note_alteration" : "natural",
                              "added_type" : null,
                              "added_alteration" : "natural"
                            }
                          },
                          {
                            "id" : "9EC59B9D-A56C-453E-AADB-C7034091BB9F",
                            "step" : 19,
                            "chord" : {
                              "bass_note" : null,
                              "seventh_type" : null,
                              "root_note" : "D",
                              "root_note_alteration" : "natural",
                              "extended_type" : null,
                              "id" : "21AA6C61-19E3-472B-8A62-E9247BA0B63C",
                              "suspended_type" : null,
                              "added_alteration" : "natural",
                              "bass_note_alteration" : null,
                              "added_type" : null,
                              "chord_type" : "major"
                            }
                          }
                        ],
                        "id" : "CAB9861D-5DCE-4BC4-92F3-D2075F029E10"
                      }
                    }
                  ],
                  "name" : "Verse 1",
                  "position" : 0
                }
              ],
              "chords" : [

              ],
              "id" : "B3CD0C19-422F-4E26-A10B-FD14E75297E5",
              "key" : "C Major",
              "title" : "Test Song",
              "artist" : null
            }            
            """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let song = try JSONDecoder().decode(Song.self, from: jsonData)
            
            var found = false
            
            let plainTextRenderer = PlainTextSongRenderer()
            print (plainTextRenderer.render(song: song))
            
        } catch {
            print("Decoding error: \(error)")
            #expect(Bool(false), "JSON Error")
        }

    }
}
