//
//  SongPerformanceViewModel.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import Foundation


class SongPerformanceViewModel {
    var playlist: Playlist
    var currentSongPerformance: SongPerformance?
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
}
