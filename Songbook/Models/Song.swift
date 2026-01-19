//
//  Song.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Song: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var title: String
    var key: String?
    var artist: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Section.song)
    var sections: [Section]
    
    @Relationship(deleteRule: .cascade, inverse: \SongPerformance.song)
    var songPerformances: [SongPerformance] = []
    
    init(id: UUID, title: String, sections: [Section], key: String? = nil, artist: String? = nil) {
        self.id = id
        self.title = title
        self.sections = sections
        self.key = key
        self.artist = artist
    }
    
    static var emptySong: Song {
        Song(id: UUID(), title: "", sections: [])
    }
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Optional: for human-readable JSON
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Error encoding user to JSON: \(error)")
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case sections
        case key
        case chords
        case artist
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.sections = try container.decode([Section].self, forKey: .sections)
        self.key = try container.decodeIfPresent(String.self, forKey: .key)
        self.artist = try container.decodeIfPresent(String.self, forKey: .artist)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(sections, forKey: .sections)
        try container.encode(key, forKey: .key)
        try container.encode(artist, forKey: .artist)
    }
}
