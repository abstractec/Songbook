//
//  SongPerformanceManager.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import Foundation
import SwiftData

class SongPerformanceManager {
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func moveUp(_ performance: SongPerformance, in playlist: Playlist) {
        if (performance.position > 0) {
            if let replacement = playlist.songPerformances.filter({ $0.position == performance.position - 1 }).first {
                let originalPosition = performance.position
                performance.position = originalPosition - 1
                replacement.position = originalPosition
            }
        }

        setPerformancePositions(in: playlist)
    }

    func moveDown(_ performance: SongPerformance, in playlist: Playlist) {
        if (performance.position < playlist.songPerformances.count - 1) {
            if let replacement = playlist.songPerformances.filter({ $0.position == performance.position + 1 }).first {
                let originalPosition = performance.position
                performance.position = originalPosition + 1
                replacement.position = originalPosition
            }
        }

        setPerformancePositions(in: playlist)
    }

    func delete(_ performance: SongPerformance, from playlist: Playlist) {
        if let idx = playlist.songPerformances.firstIndex(of: performance) {
            playlist.songPerformances.remove(at: idx)
        }
        
        modelContext?.delete(performance)
               
        setPerformancePositions(in: playlist)
    }

    private func setPerformancePositions(in playlist: Playlist) {
        let songPerformances = playlist.songPerformances.sorted(by: { $0.position < $1.position })
        var idx = 0
        
        for songPerformance in songPerformances {
            songPerformance.position = idx
            idx += 1
        }
        
    }
}
