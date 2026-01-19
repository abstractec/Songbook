//
//  Section.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Section: Identifiable, Hashable, Codable {
    @Attribute(.unique) public var id: UUID
    public var name: String
    var song: Song?
    var position: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Phrase.section)
    var phrases: [Phrase]

    init(id: UUID, name: String, song: Song? = nil, phrases: [Phrase], position: Int = 0) {
        self.id = id
        self.name = name
        self.song = song
        self.phrases = phrases
        self.position = position
    }
    
    static var emptySection: Section {
        Section(id: UUID(), name: "", song: Song.emptySong, phrases: [])
    }
    
    func copy() -> Section {
        var phrases: [Phrase] = []
        
        for phrase in self.phrases {
            phrases.append(phrase.copy())
        }
        
        return Section(id: UUID(), name: name, song: song, phrases: phrases, position: position)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case song
        case position
        case phrases
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
//        self.song = try container.decode(Song.self, forKey: .song)
        self.position = try container.decode(Int.self, forKey: .position)
        self.phrases = try container.decode([Phrase].self, forKey: .phrases)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(phrases, forKey: .phrases)
    }
}
