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
    var numberOfSongs: Int { songs.count }

    var playlists: [Playlist] = []
    var numberOfPlaylists: Int { playlists.count }

    var chords: [Chord] = []
    var numberOfChords: Int { chords.count }

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        if let modelContext = self.modelContext {
            let dataLoader = DataRepository(modelContext: modelContext)
            
            self.songs = dataLoader.loadItems(fetchDescriptor: FetchDescriptor<Song>())
            self.playlists = dataLoader.loadItems(fetchDescriptor: FetchDescriptor<Playlist>())
            self.chords = dataLoader.loadItems(fetchDescriptor: FetchDescriptor<Chord>())
        }
    }
    
    
    
}
