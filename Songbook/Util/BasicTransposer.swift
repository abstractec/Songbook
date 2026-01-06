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
        let newSection = section.copy()
        newSection.phrases.removeAll()
        
        for phrase in section.phrases {
            newSection.phrases.append(transpose(phrase: phrase, by: semitones))
        }
                
        return newSection
    }
    
    func transpose(phrase: Phrase, by semitones: Int) -> Phrase {
        let newPhrase = phrase.copy()
        newPhrase.chordSequence.sequence.removeAll()
                
        for step in phrase.chordSequence.sequence {
            let oldChord = step.chord
            
            if let (transposed, alteration) = noteTransposer(step.chord.rootNote, alteration: step.chord.rootNoteAlteration, by: semitones) {
                let newChord = oldChord.copy()
                newChord.rootNote = transposed
                newChord.rootNoteAlteration = alteration
                
                let newStep = ChordSequenceStep(id: UUID(), chord: newChord, step: step.step)
                newPhrase.chordSequence.sequence.append(newStep)
            }
        }
        
        return newPhrase
    }

    func noteTransposer(_ note: Note, alteration: Alteration, by semitones: Int = 0, preferFlats: Bool? = false) -> (Note, Alteration)? {
        if var idx = noteNameList.firstIndex(of: note.rawValue) {
            var steps = semitones

            if (steps < 0) {
                // normalize our steps if we're transposing up for a capo
                steps += 12
            }
            
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
            
            if (idx >= noteNameList.count) {
                idx = idx % 12
            }
            
            let rawNote = noteNameList[idx]
            if (rawNote.contains("#")) {
                // then we're sharp
                if let preferFlats = preferFlats, preferFlats {
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
    
    // we're only dealing with default western scale here. Microtonal stuff will need a more complicated Transposer that's above my knowledge
    private var noteNameList = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    
}

