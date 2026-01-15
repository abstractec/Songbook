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

    func delete(_ performance: SongPerformance) {
        modelContext?.delete(performance)
        
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
    
    func attach(_ instrument: Instrument, with configuration: InstrumentConfiguration? = nil, to song: Song) {
        
    }

    var title: String {
        playlist.name
    }
    
    var songPerformances: [SongPerformance] {
        playlist.songPerformances.sorted(by: { $0.position < $1.position })
    }
    
    func render(instrument: Instrument, configuration: InstrumentConfiguration? = nil) -> String {
        let instrumentRenderer = PlainTextInstrumentRenderer()
        return instrumentRenderer.render(instrument: instrument, andConfiguration: configuration)
    }
    

}
