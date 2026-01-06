//
//  NewSongViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Observable
class EditSongViewModel {
    private var modelContext: ModelContext?
    
    var name: String = ""
    var artist: String = ""
    var key: String = ""
    
    var song: Song?
    
    var sections: [SectionViewModel] = []
    
    init(song: Song?, modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        self.song = song
        
        // initialise the elements
        
        if let song = self.song {
            for section in song.sections {
                sections.append(SectionViewModel(song: song, section: section))
            }
        }
    }
    
    func save() {
        guard let context = modelContext else {
            print("Model context is not available")
            return
        }

//        init(id: UUID, title: String, sections: [Section], key: String? = nil, capo: Int? = nil, chords: [Chord] = []) {

        let song = Song(id: UUID(), title: name, sections: [Section]())
        song.artist = self.artist
       
        
        if key.count > 0 {
            song.key = key
        }
        
        print("inserting?? \(song.title)")

        
        context.insert(song)
        let fetchDescriptor = FetchDescriptor<Song>()

        do {
            try context.save()
            
            let songs = try context.fetch(fetchDescriptor)
            print(songs)
        } catch {
            print("fetch failed: \(error)")
        }
        
    }
}
