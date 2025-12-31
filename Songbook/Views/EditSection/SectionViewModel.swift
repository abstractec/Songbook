//
//  SectionViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

@Observable
class SectionViewModel: Identifiable {
    var song: Song
    var name: String = ""
    var section: Section?
    
    init(song: Song, section: Section?) {
        self.song = song
        self.section = section
    }
    
    func save() {
        // add the section to the song
        if section == nil {
        }
        
        if let section = section {
            section.name = name
            section.song = song
        }
    }
}
