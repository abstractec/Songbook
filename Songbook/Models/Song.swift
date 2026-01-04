//
//  Song.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Song: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var key: String?
    var capo: Int?
    var chords: [Chord]
    var artist: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Section.song)
    var sections: [Section]
    
    init(id: UUID, title: String, sections: [Section], key: String? = nil, capo: Int? = nil, chords: [Chord] = [], artist: String? = nil) {
        self.id = id
        self.title = title
        self.sections = sections
        self.key = key
        self.capo = capo
        self.chords = chords
        self.artist = artist
    }
    
    static var emptySong: Song {
        Song(id: UUID(), title: "", sections: [])
    }
}
