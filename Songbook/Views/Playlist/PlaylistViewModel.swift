//
//  SongPerformanceViewModel.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import Foundation
import SwiftData

class PlaylistViewModel {
    var playlist: Playlist
    var currentSongPerformance: SongPerformance?
    var modelContext: ModelContext?
    
    init(playlist: Playlist, modelContext: ModelContext) {
        self.playlist = playlist
        self.modelContext = modelContext
    }
    
    var title: String {
        playlist.name
    }
    
    var songPerformances: [SongPerformance] {
        playlist.songPerformances.sorted(by: { $0.position < $1.position })
    }
    
    func moveUp(_ performance: SongPerformance) {
        if (performance.position > 0) {
            if let replacement = playlist.songPerformances.filter({ $0.position == performance.position - 1 }).first {
                let originalPosition = performance.position
                performance.position = originalPosition - 1
                replacement.position = originalPosition
            }
        }

        setPerformancePositions()
    }

    func moveDown(_ performance: SongPerformance) {
        if (performance.position < playlist.songPerformances.count - 1) {
            if let replacement = playlist.songPerformances.filter({ $0.position == performance.position + 1 }).first {
                let originalPosition = performance.position
                performance.position = originalPosition + 1
                replacement.position = originalPosition
            }
        }

        setPerformancePositions()
    }
    
    private func setPerformancePositions() {
        let songPerformances = playlist.songPerformances.sorted(by: { $0.position < $1.position })
        var idx = 0
        
        for songPerformance in songPerformances {
            songPerformance.position = idx
            idx += 1
        }
        
    }
}

extension PlaylistViewModel: SongPerformanceRowViewModelBuilder {
    func buildSongPerformanceRowViewModel(for songPerformance: SongPerformance) -> SongPerformanceRowViewModel {
        let viewModel = SongPerformanceRowViewModel(songPerformance: songPerformance, playlist: playlist, modelContext: modelContext)
        
        return viewModel

    }
    
    
}
