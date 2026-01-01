//
//  Section.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Section: Identifiable, Hashable {
    public var id: UUID
    public var name: String
    var song: Song
    var position: Int = 0

    @Relationship(inverse: \Phrase.sections) var phrases: [Phrase]

    init(id: UUID, name: String, song: Song, phrases: [Phrase]) {
        self.id = id
        self.name = name
        self.song = song
        self.phrases = phrases
    }
    
    static var emptySection: Section {
        Section(id: UUID(), name: "", song: Song.emptySong, phrases: [])
    }
    
    func copy() -> Section {
        var phrases: [Phrase] = []
        
        for phrase in self.phrases {
            phrases.append(phrase.copy())
        }
        
        return Section(id: UUID(), name: name, song: song, phrases: phrases)
    }

}
