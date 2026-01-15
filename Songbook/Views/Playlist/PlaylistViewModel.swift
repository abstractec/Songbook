//
//  PlaylistViewModel.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import Foundation
import SwiftData

@Observable
class PlaylistViewModel {
    private var modelContext: ModelContext?
    private var playlist: Playlist
    
    init(playlist: Playlist, modelContext: ModelContext? = nil) {
        self.playlist = playlist
        self.modelContext = modelContext
    }
    
    func delete(_ playlist: Playlist) {
        // TODO: confirmation message
    }
    
    func moveUp(_ performance: SongPerformance) {
        
    }

    func moveDown(_ performance: SongPerformance) {
        
    }

    func delete(_ performance: SongPerformance) {
        
    }

    var title: String {
        playlist.name
    }
    
    var songPerformances: [SongPerformance] {
        playlist.songPerformances
    }

}
