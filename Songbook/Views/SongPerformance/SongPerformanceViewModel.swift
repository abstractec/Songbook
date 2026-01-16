//
//  SongPerformanceViewModel.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import Foundation
import SwiftData

@Observable
class SongPerformanceViewModel {
    var playlist: Playlist
    var currentSongPerformance: SongPerformance?
    var modelContext: ModelContext?
    var performanceStage: PerformanceStage = .preSong
    
    var currentSection: Section?
    
    init(playlist: Playlist, modelContext: ModelContext) {
        self.playlist = playlist
        self.modelContext = modelContext
        
        self.currentSongPerformance = self.playlist.songPerformances.sorted(by: { $0.position < $1.position}).first
    }
    
    var title: String {
        playlist.name
    }
    
    var songPerformances: [SongPerformance] {
        playlist.songPerformances.sorted(by: { $0.position < $1.position })
    }
    
    var currentSongTitle: String {
        currentSongPerformance?.song.title ?? "Not set"
    }
    
    var currentSongArtist: String {
        currentSongPerformance?.song.artist ?? "Not set"
    }
    
    var showChangeCapo: Bool {
        if (currentSongPerformance?.position == 0 && currentSongPerformance?.instrumentConfiguration?.capoPosition != nil) {
            return true
        } else if let previousSongPerformance = previousSongPerformance, let previousCapoPosition = previousSongPerformance.instrumentConfiguration?.capoPosition {
            if let currentCapoPosition = currentSongPerformance?.instrumentConfiguration?.capoPosition {
                if (previousCapoPosition != currentCapoPosition) {
                    return true
                }
                
                return false
            } else {
                return true
            }
        } else if previousSongPerformance != nil && currentSongPerformance?.instrumentConfiguration?.capoPosition != nil {
            return true
        }
        
        return false
    }
    
    var capoPosition: Int {
        currentSongPerformance?.instrumentConfiguration?.capoPosition ?? 0
    }
    
    func perform() {
        performanceStage = .inSong
        
        currentSection = currentSongPerformance?.song.sections.sorted(by: { $0.position < $1.position }).first
    }

    var previousSongPerformance: SongPerformance? {
        if self.currentSongPerformance?.position == 0 {
            return nil
        } else {
            if let currentPerformance = self.currentSongPerformance, let previousPerformance = self.playlist.songPerformances.filter({$0.position == currentPerformance.position - 1}).first {
                return previousPerformance
            }
            
            return nil
        }
    }
 
    func render(section: Section?) -> String {
        if let section = section {
            let renderer = PlainTextSongRenderer()
            return renderer.render(section: section)
        }
        
        return ""
    }
    
    func nextSection() {
        if let currentSection = self.currentSection {
            
            if let nextSection = currentSongPerformance?.song.sections.filter({$0.position == currentSection.position + 1}).first {
                self.currentSection = nextSection
            } else {
                nextSong()
            }
        } else {
            nextSong()
        }
    }
    
    func nextSong() {
        // end of the song, next song?
    
        if let currentPerformance = self.currentSongPerformance, let nextPerformance = self.playlist.songPerformances.filter({$0.position == currentPerformance.position + 1}).first {
            self.currentSongPerformance = nextPerformance
            self.currentSection = self.currentSongPerformance?.song.sections.sorted(by: {$0.position < $1.position}).first
            
            performanceStage = .preSong
        } else {
            performanceStage = .finished

        }

    }
}

enum PerformanceStage: String, CaseIterable {
    case preSong
    case inSong
    case finished
}
