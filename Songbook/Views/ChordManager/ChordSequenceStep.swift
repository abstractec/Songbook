//
//  ChordSequenceStep.swift
//  Songbook
//
//  Created by John Haselden on 01/01/2026.
//

import Foundation
import SwiftData

@Model
final class ChordSequenceStep: Identifiable, Codable {
    @Attribute(.unique) public var id: UUID
    public var chord: Chord
    public var step: Int
    var chordSequence: ChordSequence?

    
    init(id: UUID, chord: Chord, step: Int, chordSequence: ChordSequence? = nil) {
        self.id = id
        self.chord = chord
        self.step = step
        self.chordSequence = chordSequence
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chord
        case step
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.chord = try container.decode(Chord.self, forKey: .chord)
        self.step = try container.decode(Int.self, forKey: .step)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(chord, forKey: .chord)
        try container.encode(step, forKey: .step)
    }
}
