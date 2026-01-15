//
//  PlaylistsViewModel.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import Foundation
import SwiftData

@Observable
class PlaylistsViewModel {
    private var modelContext: ModelContext?
    
    var playlistName: String = ""
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func delete(_ playlist: Playlist) {
        // TODO: confirmation message
    }
    
    func addPlaylist(with name: String) {
        let playlist = Playlist(id: UUID(), name: name, songPerformances: [])
        
        modelContext?.insert(playlist)
        
        do {
            try modelContext?.save()
        } catch {
            // TODO: error message
        }
        
    }
    

}
