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
    public var id: UUID
    public var sequence: [ChordSequenceStep]
    
    init(id: UUID, sequence: [ChordSequenceStep]) {
        self.id = id
        self.sequence = sequence
    }
}
