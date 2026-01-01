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
        
//        self.sections = song.sections
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
        if (section.position >= 0) {
            if let replacement = song.sections.filter({ $0.position == section.position - 1 }).first {
                let originalPosition = section.position
                section.position = originalPosition - 1
                replacement.position = originalPosition
            }
        }
        
        // re-index our items
        reIndexSections()

    }

    func moveDown(section: Section) {
        if (section.position < song.sections.count - 1) {
            if let replacement = song.sections.filter({ $0.position == section.position + 1 }).first {
                let originalPosition = section.position
                section.position = originalPosition + 1
                replacement.position = originalPosition
            }
        }

        // re-index our items
        reIndexSections()
    }

    func duplicate(section: Section) {
        let newSection = section.copy()
        newSection.position = song.sections.count
        song.sections.append(newSection)
        
        // re-index our items
        reIndexSections()
    }
    
    func delete(section: Section) {
        modelContext?.delete(section)
        
        // re-index our items
        reIndexSections()
    }

    func remove(section: Section) {
        let idx = song.sections.firstIndex(of: section)
        
        if let idx = idx {
            song.sections.remove(at: idx)
            
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
    
    private func reIndexSections() {
        var lastIdx = 0;
        for section in song.sections.sorted(by: { $0.position < $1.position }) {
            if section.position != lastIdx {
                section.position = lastIdx
            }
            lastIdx += 1
        }
    }

}
