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
    var section: Section?
    var phrases: [Phrase] {
        if let section = self.section {
            return section.phrases.sorted(by: {$0.position < $1.position })
        } else {
            return []
        }
    }
    var modelContext: ModelContext?
    
    init(song: Song, section: Section?, modelContext: ModelContext? = nil) {
        self.song = song
        self.section = section
        self.modelContext = modelContext
        
        if let name = section?.name {
            self.name = name
        }
    }
    
    func save() {
        // add the section to the song
        if section == nil {
            section = Section(id: UUID(), name: self.name, song: self.song, phrases: [])
        }
        
        if let section = section {
            section.name = name
            section.song = song
            song.sections.append(section)
        }
    }
    
    func reload() {
//        if let section = section {
//            self.phrases = section.phrases.sorted{ $0.position < $1.position }
//        }
//
    }
    
    func render(phrase: Phrase) -> String {
        let songRenderer = PlainTextSongRenderer()
        
        return songRenderer.render(phrase: phrase)
    }
    
    func moveUp(phrase: Phrase) {
        if let section = section {
            let idx = section.phrases.firstIndex(of: phrase)
            
            if let idx = idx {
                section.phrases[idx].position -= 1
                section.phrases[idx - 1].position += 1
                section.phrases.move(from: idx, to: idx - 1)
            }
        }
        setPhrasePositions()
    }

    func moveDown(phrase: Phrase) {
        if let section = section {
            let idx = section.phrases.firstIndex(of: phrase)

            if let idx = idx {
                section.phrases[idx].position += 1
                section.phrases[idx - 1].position -= 1
                section.phrases.move(from: idx, to: idx + 1)
            }
        }

        setPhrasePositions()
    }
    
    private func setPhrasePositions() {
        var i = 0;
        
        for phrase in self.phrases.sorted(by: { $0.position < $1.position }) {
            phrase.position = i
            i += 1
        }
    }
    
    func duplicate(phrase: Phrase) {
        if let section = section {
            section.phrases.append(phrase.copy())
        }

        setPhrasePositions()
    }
    
    func delete(phrase: Phrase) {
        modelContext?.delete(phrase)
    }
}
