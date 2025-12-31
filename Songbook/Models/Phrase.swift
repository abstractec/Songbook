//
//  Phrase.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Phrase: Identifiable {
    public var id: UUID
    var sections: [Section]
    var lyric: Lyric?
    var chordSequence: ChordSequence?
    var chordSequenceRepeatCount: Int?
    
    public init(
        id: UUID = .init(),
        sections: [Section] = [],
        lyric: Lyric? = nil,
        chordSequence: ChordSequence? = nil,
        chordSequenceRepeatCount: Int? = nil,
    ) {
        self.id = id
        self.sections = sections
        self.lyric = lyric
        self.chordSequence = chordSequence
        self.chordSequenceRepeatCount = chordSequenceRepeatCount
    }

    
}
