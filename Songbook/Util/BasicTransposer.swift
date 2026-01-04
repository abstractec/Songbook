//
//  File.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation

class BasicTransposer: Transposer {
    func transpose(song: Song, by semitones: Int) -> Song {
        // TODO: make this work
        return song
    }
    
    func transpose(section: Section, by semitones: Int) -> Section {
        // TODO: make this work
        return section
    }
    
    func transpose(phrase: Phrase, by semitones: Int) -> Phrase {
        // TODO: make this work
        
        return phrase
    }

    func noteTransposer(_ note: Note, alteration: Alteration, steps: Int, preferFlats: Bool? = false) -> (Note, Alteration)? {
        if var idx = noteNameList.firstIndex(of: note.rawValue) {
            if alteration == .sharp {
                idx += 1
            } else if alteration == .flat {
                idx -= 1
            }
            
            // normalise our steps
            idx += steps % 12
            
            if (idx == 0) {
                return (note, alteration)
            }
            
            if (idx < 0) {
              idx = noteNameList.count + idx
            }
            
            let rawNote = noteNameList[idx]
            if (rawNote.contains("#")) {
                // then we're sharp
                if let flats = preferFlats, flats {
                    var flatIdx = idx + 1
                    if (flatIdx >= noteNameList.count) {
                        flatIdx = 0
                    }
                    
                    if let actualNote = Note(rawValue: noteNameList[flatIdx]) {
                        // need to check our bounds here
                        return (actualNote, Alteration.flat)
                    }
                } else {
                    if let actualNote = Note(rawValue: noteNameList[idx - 1]) {
                        // don't have to check for bounds here
                        return (actualNote, Alteration.sharp)
                    }
                }
            } else {
                if let actualNote = Note(rawValue: rawNote) {
                    return (actualNote, Alteration.natural)
                }

            }
        }
        
        
        return nil
        
    }
    
    private var noteNameList = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    
}

