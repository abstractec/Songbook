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
    public var document: JSONDocument?
    public var isExporting = false
    public var isImporting = false
    
    public var showDeleteConfirmation: Bool = false

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
    }
    
    func confirmDeletion(chord: Chord) {
        showDeleteConfirmation.toggle()
    }
    
    func delete(chord: Chord) {
        showDeleteConfirmation.toggle()
        
        if let modelContext = modelContext {
            
            do {
                let predicate = #Predicate<ChordSequenceStep> { step in
                    step.chord.id == chord.id
                }
                let descriptor = FetchDescriptor<ChordSequenceStep>(predicate: predicate)
                
                let stepsToDelete = try modelContext.fetch(descriptor)
                
                // Delete each step first
                for step in stepsToDelete {
                    modelContext.delete(step)
                }
                
                // Finally, delete the chord itself
                modelContext.delete(chord)
            } catch {
                // TODO: error
                print("something went wrong here")
            }
        }
    }
    
    func longName(for chord: Chord) -> String {
        return chordRenderer.render(chord: chord)
    }

    func shortName(for chord: Chord) -> String {
        return chordRenderer.renderShortName(chord: chord)
    }

    func exportChords(_ chords: [Chord]) {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        if let encodedData = try? encoder.encode(chords) {
            self.document = JSONDocument(data: encodedData)
            self.isExporting = true
        }
    }
    
    func importChords(from url: URL) {
        isImporting = true
        
        guard url.startAccessingSecurityScopedResource() else {
                print("Permission denied")
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedChords = try decoder.decode([Chord].self, from: data)
                
                // check if we have any of these chords
                
                if let chords = try modelContext?.fetch(FetchDescriptor<Chord>()) {
                    
                    for chord in decodedChords {
                        var found = false
                        // yes this is inefficient, but it's Sunday and I want a beer
                        for origChord in chords {
                            if (origChord == chord) {
                                found = true
                            }
                        }
                        
                        if !found {
                            modelContext?.insert(chord)
                        }
                    }
                } else {
                    for chord in decodedChords {
                        modelContext?.insert(chord)
                    }
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
    }

}
