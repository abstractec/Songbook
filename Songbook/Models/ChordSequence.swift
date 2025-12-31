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
    public var chords: [Chord]
    public var spacing: [Int]
    
    init(id: UUID, chords: [Chord], spacing: [Int]) {
        self.id = id
        self.chords = chords
        self.spacing = spacing
    }
}
