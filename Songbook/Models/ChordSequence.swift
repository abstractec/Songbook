//
//  ChordSequence.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class ChordSequence: Identifiable, Codable {
    public var id: UUID
    
    @Relationship(deleteRule: .cascade, inverse: \ChordSequenceStep.chordSequence)
    public var sequence: [ChordSequenceStep]
    
    init(id: UUID, sequence: [ChordSequenceStep]) {
        self.id = id
        self.sequence = sequence
    }
    
    func copy() -> ChordSequence {
        var sequence: [ChordSequenceStep] = []
        
        for step in self.sequence {
            sequence.append(ChordSequenceStep(id: UUID(), chord: step.chord, step: step.step))
        }
        return ChordSequence(id: UUID(), sequence: sequence)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case sequence
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.sequence = try container.decode([ChordSequenceStep].self, forKey: .sequence)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sequence, forKey: .sequence)
    }
}
