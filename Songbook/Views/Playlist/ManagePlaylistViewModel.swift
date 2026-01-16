//
//  ManagePlaylistViewModel.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import Foundation
import SwiftData

@Observable
class ManagePlaylistViewModel: SongPerformanceManager {
    var playlist: Playlist
    
    init(playlist: Playlist, modelContext: ModelContext? = nil) {
        self.playlist = playlist
        
        super.init(modelContext: modelContext)
    }
    
    func delete(_ playlist: Playlist) {
        // TODO: confirmation message
    }
    
    func attach(_ instrument: Instrument, with configuration: InstrumentConfiguration? = nil, to song: Song) {
        let songPerformance = SongPerformance(id: UUID(), song: song, instrument: instrument, instrumentConfiguration: configuration, position: playlist.songPerformances.count)
        
        modelContext?.insert(songPerformance)
        
        playlist.songPerformances.append(songPerformance)
        
        do {
            try modelContext?.save()
        } catch {
            // TODO: error message
        }
        
        
    }
    
    var title: String {
        playlist.name
    }
    
    var songPerformances: [SongPerformance] {
        playlist.songPerformances
            .filter { $0.modelContext != nil }
            .sorted(by: { $0.position < $1.position })
    }
    
    func render(instrument: Instrument, configuration: InstrumentConfiguration? = nil) -> String {
        let instrumentRenderer = PlainTextInstrumentRenderer()
        return instrumentRenderer.render(instrument: instrument, andConfiguration: configuration)
    }
}

extension ManagePlaylistViewModel: SongPerformanceRowViewModelBuilder {
    func buildSongPerformanceRowViewModel(for songPerformance: SongPerformance) -> SongPerformanceRowViewModel {
        let viewModel = SongPerformanceRowViewModel(songPerformance: songPerformance, playlist: playlist, modelContext: modelContext)
        
        return viewModel
    }
}
