//
//  ChordSequence.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class ChordSequence: Identifiable {
    @Attribute(.unique) public var id: UUID
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
}
