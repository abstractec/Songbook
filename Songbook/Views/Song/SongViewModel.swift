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
    
    // leave these two here for when we pass an instrument in for this view model
    let showCapo: Bool = false
    let capo: String = ""
        
    var inEditMode: Bool = false
    var modelContext: ModelContext?
    
    var transposedBy: Int = 0
    
    init(song: Song, modelContext: ModelContext?) {
        self.song = song
        
        if let key = self.song.key {
            self.showKey = true
            self.key = key
        } else {
            self.showKey = false
            self.key = ""
        }
        
        self.modelContext = modelContext
        
    }
    
    func render(phrase: Phrase) -> String {
        let songRenderer = PlainTextSongRenderer()
        
        return songRenderer.render(phrase: phrase, transposedBy: self.transposedBy)
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
    
    func addSection(after section: Section) {
        let position = section.position
        
        let newSection = Section.emptySection
        newSection.name = "New Section"
        
        newSection.position = position + 1
        song.sections.insert(newSection, at: song.sections.firstIndex(of: section)! + 1)
        
        reIndexSections()
    }
    
    func increaseTransposition() {
        transposedBy += 1
    }
    
    func decreaseTransposition() {
        transposedBy -= 1
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
