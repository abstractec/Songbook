//
//  ContentViewModel.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import Foundation
import SwiftData

@Observable
class ContentViewModel {
    private var modelContext: ModelContext?
    var songs: [Song] = []

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        loadSongs()
    }
    
    
    
    private func loadSongs() {
        let fetchDescriptor = FetchDescriptor<Song>()
        if let modelContext = self.modelContext {
            
            do {
                self.songs = try modelContext.fetch(fetchDescriptor)
                
                // 3. Process the results (e.g., update UI, print to console).
                for song in songs {
                    print("Found movie: \(song.title)")
                }
            } catch {
                // 4. Handle any potential errors during the fetch.
                print("Failed to load Song models: \(error.localizedDescription)")
            }
        }
    }
    
    
}
