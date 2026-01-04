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
    @Attribute(.unique) public var id: UUID
    var sections: [Section]
    var lyric: Lyric = Lyric(id: UUID(), text: "")
    var chordSequence: ChordSequence = ChordSequence(id: UUID(), sequence: [])
    var chordSequenceRepeatCount: Int?
    var position: Int = 0
    
    public init(
        id: UUID = .init(),
        sections: [Section] = [],
        lyric: Lyric? = nil,
        chordSequence: ChordSequence? = nil,
        chordSequenceRepeatCount: Int? = nil,
    ) {
        self.id = id
        self.sections = sections
        
        if let lyric = lyric {
            self.lyric = lyric
        }
        
        if let chordSequence = chordSequence {
            self.chordSequence = chordSequence
        }
        
        self.chordSequenceRepeatCount = chordSequenceRepeatCount
    }

    static var emptyPhrase: Phrase {
        Phrase(id: UUID())
    }
    
    func copy() -> Phrase {
        
        return Phrase(id: UUID(), sections: [], lyric: self.lyric.copy(), chordSequence: self.chordSequence.copy(), chordSequenceRepeatCount: self.chordSequenceRepeatCount)
    }

}
