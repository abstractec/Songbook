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
    var chords: [Chord] = []

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        loadChords()
    }
    
    
    private func loadChords() {
        
        if let modelContext = modelContext {
            do {
                let allChords = try modelContext.fetch(FetchDescriptor<Chord>())
                self.chords = Array(allChords)
            } catch {
                print("Failed to load chords")
            }
        }
    }
    
    func delete(chord: Chord) {
        if let modelContext = modelContext {
            modelContext.delete(chord)
            loadChords()
        }
    }
    
}
