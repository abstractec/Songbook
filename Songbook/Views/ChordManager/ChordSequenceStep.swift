//
//  ChordSequenceStep.swift
//  Songbook
//
//  Created by John Haselden on 01/01/2026.
//

import Foundation
import SwiftData

@Model
final class ChordSequenceStep: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var chord: Chord
    public var step: Int
    
    init(id: UUID, chord: Chord, step: Int) {
        self.id = id
        self.chord = chord
        self.step = step
    }
}
