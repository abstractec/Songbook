//
//  SectionViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Observable
class SectionViewModel: Identifiable {
    var song: Song
    var name: String = ""
    var section: Section = .emptySection
    
    var phrases: [Phrase] {
        return self.section.phrases.sorted(by: {$0.position < $1.position })
    }
    var modelContext: ModelContext?
    
    init(song: Song, section: Section?, modelContext: ModelContext? = nil) {
        self.song = song
        if let section = section {
            self.section = section
        }
        self.modelContext = modelContext
        
        if let name = section?.name {
            self.name = name
        }
    }
    
    func save() {
        // add the section to the song
        section.name = name
        section.song = song
        song.sections.append(section)
    }
    
    func reload() {
    }
    
    func render(phrase: Phrase) -> String {
        let songRenderer = PlainTextSongRenderer()
        
        return songRenderer.render(phrase: phrase)
    }
    
    func moveUp(phrase: Phrase) {
        if (phrase.position > 0) {
            if let replacement = section.phrases.filter({ $0.position == phrase.position - 1 }).first {
                let originalPosition = phrase.position
                phrase.position = originalPosition - 1
                replacement.position = originalPosition
            }
        }
        
        setPhrasePositions()
    }

    func moveDown(phrase: Phrase) {
        if (phrase.position < section.phrases.count - 1) {
            if let replacement = section.phrases.filter({ $0.position == phrase.position + 1 }).first {
                let originalPosition = phrase.position
                phrase.position = originalPosition + 1
                replacement.position = originalPosition
            }
        }

        setPhrasePositions()
    }
    
    private func setPhrasePositions() {
        let phrases = self.section.phrases.sorted(by: { $0.position < $1.position })
        var idx = 0
        
        for phrase in phrases {
            phrase.position = idx
            idx += 1
        }
        
    }
    
    func duplicate(phrase: Phrase) {
        section.phrases.append(phrase.copy())

        setPhrasePositions()
    }
    
    func delete(phrase: Phrase) {
        modelContext?.delete(phrase)
        
        setPhrasePositions()
    }
}
