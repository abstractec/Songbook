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

    public var root: String = ""
    public var rootAccidental: NoteAccidentalType = .natural
    public var chordType: ChordType = .major
    public var altered: Bool = false
    public var alteration: Double = 0.0
    public var alterationType: AlterationType?
    public var suspended: Bool = false
    public var suspendedBy: Double = 0.0
    public var chord: Chord?
    
    public var displayChord: String {
        let chord = Chord(id: UUID(), name: "", shortName: "", imagePath: nil)
        chord.root = root
        chord.chordType = chordType
        chord.alteration = Int(alteration)
        chord.altered = altered
        chord.alterationType = alterationType
        chord.suspended = suspended
        chord.suspendedBy = Int(suspendedBy)
        
        let renderer = PlainTextChordRenderer()
        
        return renderer.render(chord: chord)
    }
    
    public var displayShortChord: String {
        let chord = Chord(id: UUID(), name: "", shortName: "", imagePath: nil)
        chord.root = root
        chord.chordType = chordType
        chord.alteration = Int(alteration)
        chord.altered = altered
        chord.alterationType = alterationType
        chord.suspended = suspended
        chord.suspendedBy = Int(suspendedBy)

        let renderer = PlainTextChordRenderer()
        
        return renderer.renderShortName(chord: chord)

    }
    
    init(modelContext: ModelContext? = nil, root: String? = nil) {
        self.modelContext = modelContext
        
        if let root = root {
            self.root = root
        }
    }
    
    init(modelContext: ModelContext? = nil, chord: Chord) {
        self.modelContext = modelContext
        
        self.chord = chord
        
        if let root = chord.root {
            self.root = root
        }
        
        if let chordType = chord.chordType {
            self.chordType = chordType
        }
        
        self.altered = chord.altered
        
        if let alteration = chord.alteration {
            self.alteration = Double(alteration)
        }
        self.suspended = chord.suspended
        
        if let suspendedBy = chord.suspendedBy {
            self.suspendedBy = Double(suspendedBy)
        }
    }
    
    func save() {
        // write the chord to the DB, and run away!
    }
}

enum NoteAccidentalType: String, CaseIterable, Identifiable {
    case natural
    case sharp
    case flat
    
    var id: String { self.rawValue }
}
