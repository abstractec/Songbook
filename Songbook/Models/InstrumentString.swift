//
//  String.swift
//  Songbook
//
//  Created by John Haselden on 06/01/2026.
//

import Foundation
import SwiftData

@Model
final class InstrumentString: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var note: Note
    public var noteAlteration: Alteration = Alteration.natural
    public var position: Int
    
    public init(id: UUID = .init(), note: Note, noteAlteration: Alteration = .natural, position: Int) {
        self.id = id
        self.note = note
        self.noteAlteration = noteAlteration
        self.position = position
    }
    
    func copy() -> InstrumentString {
        return InstrumentString(id: UUID(), note: note, noteAlteration: noteAlteration, position: position)
    }
}


