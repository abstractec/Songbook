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
    var position: Int = 0
    var repeats: Int = 1
    
    public init(
        id: UUID = .init(),
        sections: [Section] = [],
        lyric: Lyric? = nil,
        chordSequence: ChordSequence? = nil,
        repeats: Int = 1
    ) {
        self.id = id
        self.sections = sections
        
        if let lyric = lyric {
            self.lyric = lyric
        }
        
        if let chordSequence = chordSequence {
            self.chordSequence = chordSequence
        }
        
        self.repeats = repeats
    }

    static var emptyPhrase: Phrase {
        Phrase(id: UUID())
    }
    
    func copy() -> Phrase {
        return Phrase(id: UUID(), sections: [], lyric: self.lyric.copy(), chordSequence: self.chordSequence.copy(), repeats: self.repeats)
    }

}
