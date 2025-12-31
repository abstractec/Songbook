//
//  NewSongViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

@Observable
class EditSongViewModel {
    var name: String = ""
    var key: String = ""
    var capo: String = ""
    
    var song: Song?
    
    var sections: [SectionViewModel] = []
    
    init(song: Song?) {
        self.song = song
        
        // initialise the elements
        
        if let song = self.song {
            for section in song.sections {
                sections.append(SectionViewModel(song: song, section: section))
            }
        }
    }
}
