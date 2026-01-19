//
//  Phrase.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Phrase: Identifiable, Codable {
    @Attribute(.unique) public var id: UUID
    var section: Section?
    var lyric: Lyric?
    var chordSequence: ChordSequence = ChordSequence(id: UUID(), sequence: [])
    var position: Int = 0
    var repeats: Int = 1
    
    public init(
        id: UUID = .init(),
        chordSequence: ChordSequence? = nil,
        position: Int = 0,
        repeats: Int = 1
    ) {
        self.id = id
        
        if let chordSequence = chordSequence {
            self.chordSequence = chordSequence
        }
        
        self.position = position
        self.repeats = repeats
    }

    static var emptyPhrase: Phrase {
        Phrase(id: UUID())
    }
    
    func copy() -> Phrase {
        return Phrase(id: UUID(), chordSequence: self.chordSequence.copy(), position: self.position, repeats: self.repeats)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case lyric
        case sections
        case chordSequence
        case position
        case repeats
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.lyric = try container.decode(Lyric.self, forKey: .lyric)
        self.chordSequence = try container.decode(ChordSequence.self, forKey: .chordSequence)
        self.position = try container.decode(Int.self, forKey: .position)
        self.repeats = try container.decode(Int.self, forKey: .repeats)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lyric, forKey: .lyric)
        try container.encode(chordSequence, forKey: .chordSequence)
        try container.encode(position, forKey: .position)
        try container.encode(repeats, forKey: .repeats)
    }

}
