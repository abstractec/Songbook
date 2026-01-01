//
//  SongViewModel.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import Foundation
import SwiftData

@Observable
class SongViewModel {
    let song: Song
    let showKey: Bool
    let key: String
    
    let showCapo: Bool
    let capo: String
    
    var sections: [Section]
    
    var inEditMode: Bool = false
    var modelContext: ModelContext?
    
    init(song: Song, modelContext: ModelContext?) {
        self.song = song
        
        if let key = self.song.key {
            self.showKey = true
            self.key = key
        } else {
            self.showKey = false
            self.key = ""
        }
        
        if let capo = self.song.capo {
            self.showCapo = true
            self.capo = "\(capo)"
        } else {
            self.showCapo = false
            self.capo = ""
        }
        
        self.sections = song.sections
        self.modelContext = modelContext
        
    }
    
    func render(phrase: Phrase) -> String {
        let songRenderer = PlainTextSongRenderer()
        
        return songRenderer.render(phrase: phrase)
    }
    
    func toggleEditMode() {
        inEditMode.toggle()
    }
    
    func moveUp(section: Section) {
        let idx = sections.firstIndex(of: section)
        
        if let idx = idx {
            sections.move(from: idx, to: idx - 1)
        }
        
    }

    func moveDown(section: Section) {
        let idx = sections.firstIndex(of: section)
        
        if let idx = idx {
            sections.move(from: idx, to: idx + 1)
        }

    }

    func remove(section: Section) {
        let idx = sections.firstIndex(of: section)
        
        if let idx = idx {
            sections.remove(at: idx)
            
            if let modelContext = self.modelContext {
                modelContext.delete(section)
            } else {
                print("didn't have a model context??")
            }
        }
        
    }
    
    func addSection(after afterSection: Section) {
        
    }
    
    func edit(section: Section) {
        
    }
    
    func addSection() {
        
    }

}
