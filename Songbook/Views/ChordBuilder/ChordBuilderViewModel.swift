//
//  ChordBuilderViewModel.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import SwiftData

@Observable
class ChordBuilderViewModel {
    private var modelContext: ModelContext?

    public var rootNote: Note = .C
    public var rootNoteAlteration: Alteration = .natural
    public var chordType: ChordType = ChordType.major
    public var seventhType: SeventhType? = .major
    public var extendedType: ExtendedType? = nil
    public var suspendedType: SuspendedType? = nil
    public var addedType: AddedType? = nil
    public var bassNote: Note = .G
    public var bassNoteAlteration: Alteration = .natural

    public var isSuspended = false {
        didSet {
            if (!isSuspended) {
                suspendedType = nil

            }
        }
    }
    
    public var isAdded = false
    public var hasBassNote = false

    public var chord: Chord?

    public var displayChord: String {
        let chord = self.toChord()
        
        if let chord = chord {
            let renderer = PlainTextChordRenderer()
            return renderer.render(chord: chord)
        } else {
            return ""
        }
    }
    
    public var displayShortChord: String {
        let chord = self.toChord()

        if let chord = chord {
            let renderer = PlainTextChordRenderer()
            return renderer.renderShortName(chord: chord)
        } else {
            return ""
        }
    }
    
    init(modelContext: ModelContext? = nil, chord: Chord? = nil) {
        self.modelContext = modelContext
        
        if let chord = chord {
            self.chord = chord
            populateValues()
        }
    }
    
    init(modelContext: ModelContext? = nil, chord: Chord) {
        self.modelContext = modelContext
        
        self.chord = chord
        
        populateValues()
        
    }
    
    private func populateValues() {
        if let chord = self.chord {
            self.rootNote = chord.rootNote
            self.rootNoteAlteration = chord.rootNoteAlteration
            self.chordType = chord.chordType
            self.seventhType = chord.seventhType
            
            self.extendedType = chord.extendedType

            if let suspendedType = chord.suspendedType {
                self.suspendedType = suspendedType
                self.isSuspended = true
            }
            
            if let addedType = chord.addedType {
                self.addedType = addedType
                self.isAdded = true
            }
            
            if let bassNote = chord.bassNote {
                self.bassNote = bassNote
                self.hasBassNote = true

                if let bassNoteAlteration = chord.bassNoteAlteration {
                    self.bassNoteAlteration = bassNoteAlteration
                }
            }
        }

    }
    
    func save() {
        // write the chord to the DB, and run away!
        if let modelContext = self.modelContext, let chord = self.chord, let existingChord = self.findItemByCustomID(with: chord.id, in: modelContext) {
//            // we're overwriting
            existingChord.rootNote = rootNote
            existingChord.rootNoteAlteration = rootNoteAlteration
            existingChord.chordType = chordType
            existingChord.seventhType = seventhType
            existingChord.extendedType = extendedType
            existingChord.suspendedType = suspendedType
            existingChord.addedType = addedType
            
            if hasBassNote {
                existingChord.bassNote = bassNote
                existingChord.bassNoteAlteration = bassNoteAlteration
            } else {
                existingChord.bassNote = nil
                existingChord.bassNoteAlteration = nil
            }
        } else {
            // otherwise, make my chord and save it
            if let newChord = self.toChord() {
                modelContext?.insert(newChord)
                
                do {
                    try modelContext?.save()
                } catch {
                    print("Unable to save new chord: \(error)")
                }
            }
        }
        
    }
    
    func findItemByCustomID(with uuid: UUID, in modelContext: ModelContext) -> Chord? {
        do {
            let predicate = #Predicate<Chord> { $0.id == uuid }
            let descriptor = FetchDescriptor<Chord>(predicate: predicate)
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            print("Failed to fetch item: \(error)")
            return nil
        }
    }
    
    private func toChord() -> Chord? {        
        if hasBassNote {
            let chord = Chord(id: UUID(),
                              rootNote: self.rootNote,
                              rootNoteAlteration: self.rootNoteAlteration,
                              chordType: self.chordType,
                              seventhType: self.seventhType,
                              extendedType: self.extendedType,
                              suspendedType: self.suspendedType,
                              addedType: self.addedType,
                              bassNote: self.bassNote,
                              bassNoteAlteration: self.bassNoteAlteration)
            
            return chord
        } else {
            let chord = Chord(id: UUID(),
                              rootNote: self.rootNote,
                              rootNoteAlteration: self.rootNoteAlteration,
                              chordType: self.chordType,
                              seventhType: self.seventhType,
                              extendedType: self.extendedType,
                              suspendedType: self.suspendedType,
                              addedType: self.addedType)
            
            return chord
            
        
        }


    }
    

}
