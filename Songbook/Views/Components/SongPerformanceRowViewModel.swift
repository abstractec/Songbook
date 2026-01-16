//
//  SongPerformanceRowViewModel.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import Foundation
import SwiftData

class SongPerformanceRowViewModel: SongPerformanceManager {
    var songPerformance: SongPerformance
    var playlist: Playlist
    
    init(songPerformance: SongPerformance, playlist: Playlist, modelContext: ModelContext? = nil) {
        self.songPerformance = songPerformance
        self.playlist = playlist
        
        super.init(modelContext: modelContext)
    }
    
    var title: String {
        self.songPerformance.song.title
    }
    
}

protocol SongPerformanceRowViewModelBuilder {
    func buildSongPerformanceRowViewModel(for songPerformance: SongPerformance) -> SongPerformanceRowViewModel

}
