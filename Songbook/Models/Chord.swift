//
//  Chord.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Chord: Identifiable {
    // SwiftData helpers
    var rootRawValue: String

    @Attribute(.unique) public var id: UUID
    public var imagePath: String?
    public var root: NoteName {
        get { NoteName(rawValue: rootRawValue) ?? .C }
        set { rootRawValue = newValue.rawValue }
    }
    
    public var rootAlteration: Alteration = Alteration.natural
    public var chordType: ChordType = ChordType.major
    public var seventhType: SeventhType? = nil
    public var extendedType: ExtendedType? = nil
    public var suspendedType: SuspendedType? = nil
    public var addedType: AddedType? = nil
    public var addedAlteration: Alteration = Alteration.natural

    public var bassNote: NoteName?
    public var bassNoteAlteration: Alteration? = nil

    
    init(id: UUID, imagePath: String? = nil, root: NoteName, rootAlteration: Alteration = .natural, chordType: ChordType? = nil, seventhType: SeventhType? = nil, extendedType: ExtendedType? = nil, suspendedType: SuspendedType? = nil, addedType: AddedType? = nil, addedAlteration: Alteration = .natural, bassNote: NoteName? = nil, bassNoteAlteration: Alteration? = nil) {
        self.id = id
        self.imagePath = imagePath
        self.rootRawValue = root.rawValue
        self.root = root
        
        self.rootAlteration = rootAlteration
        
        if let chordType = chordType {
            self.chordType = chordType
        }
        self.seventhType = seventhType
        self.extendedType = extendedType
        self.suspendedType = suspendedType
        self.addedType = addedType
        self.addedAlteration = addedAlteration
        self.bassNote = bassNote
        self.bassNoteAlteration = bassNoteAlteration    
    }
}

enum ChordType: String, CaseIterable, Identifiable, Codable {
    case major
    case minor
    case seventh
    case diminished
    case augmented
    case power
    
    var id: String { self.rawValue }
}

enum SeventhType: String, CaseIterable, Identifiable, Codable {
    case major
    case minor
    case dominant
    case halfDimished

    var id: String { self.rawValue }
}

enum ExtendedType: String, CaseIterable, Identifiable, Codable {
    case ninth
    case eleventh
    case thirteenth
    
    var id: String { self.rawValue }
}

enum Alteration: String, CaseIterable, Identifiable, Codable {
    case natural
    case flat
    case sharp
    
    var id: String { self.rawValue }
}

enum SuspendedType: String, CaseIterable, Identifiable, Codable {
    case second
    case fourth
    
    var id: String { self.rawValue }
}

enum AddedType: String, CaseIterable, Identifiable, Codable {
    case second
    case ninth
    
    var id: String { self.rawValue }
}

enum NoteName: String, CaseIterable, Identifiable, Codable, Comparable {
    static func < (lhs: NoteName, rhs: NoteName) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case A
    case B
    case C
    case D
    case E
    case F
    case G

    var id: String { self.rawValue }
}
