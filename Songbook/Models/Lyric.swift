//
//  Lyric.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Lyric: Identifiable, Codable {
    public var id: UUID
    public var text: String
    
    public init(id: UUID = .init(), text: String) {
        self.id = id
        self.text = text
    }
    
    func copy() -> Lyric {
        return Lyric(id: UUID(), text: text)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
    }
}
