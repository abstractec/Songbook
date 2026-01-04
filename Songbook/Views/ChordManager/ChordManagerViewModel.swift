//
//  ChordManagerViewModel.swift
//  Songbook
//
//  Created by John Haselden on 01/01/2026.
//

import Foundation
import SwiftData

@Observable
class ChordManagerViewModel {
    private var modelContext: ModelContext?
    private var chordRenderer = PlainTextChordRenderer()

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
    }
    
    func delete(chord: Chord) {
        if let modelContext = modelContext {
            modelContext.delete(chord)
        }
    }
    
    func longName(for chord: Chord) -> String {
        return chordRenderer.render(chord: chord)
    }

    func shortName(for chord: Chord) -> String {
        return chordRenderer.renderShortName(chord: chord)
    }

}
