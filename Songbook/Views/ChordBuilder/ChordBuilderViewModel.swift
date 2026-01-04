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

    public var root: NoteName = .C
    public var rootAlteration: Alteration = .natural
    public var chordType: ChordType = ChordType.major
    public var seventhType: SeventhType? = .major
    public var extendedType: ExtendedType? = nil
    public var suspendedType: SuspendedType? = nil
    public var addedType: AddedType? = nil
    public var bassNote: NoteName = .G
    public var bassNoteAlteration: Alteration = .natural

    public var isSuspended = false
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
        }
        
        
    }
    
    init(modelContext: ModelContext? = nil, chord: Chord) {
        self.modelContext = modelContext
        
        self.chord = chord
        
        self.root = chord.root
        
        self.chordType = chord.chordType
        
//        self.altered = chord.altered
        
        // TODO: add all the ohter stuff
    }
    
    func save() {
        // write the chord to the DB, and run away!
        if let modelContext = self.modelContext, let chord = self.chord, let existingChord = self.findItemByCustomID(with: chord.id, in: modelContext) {
//            // we're overwriting
            existingChord.root = root
            existingChord.rootAlteration = rootAlteration
            existingChord.chordType = chordType
            existingChord.seventhType = seventhType
            existingChord.extendedType = extendedType
            existingChord.suspendedType = suspendedType
            existingChord.addedType = addedType
            existingChord.bassNote = bassNote
            existingChord.bassNoteAlteration = bassNoteAlteration
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
                              root: root,
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
                              root: root,
                              chordType: self.chordType,
                              seventhType: self.seventhType,
                              extendedType: self.extendedType,
                              suspendedType: self.suspendedType,
                              addedType: self.addedType)
            
            return chord
            
        
        }


    }
    

}
