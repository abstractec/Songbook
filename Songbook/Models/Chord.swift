//
//  Chord.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Chord: Identifiable, Codable, Comparable {
    
    // SwiftData helpers
    var rootRawValue: String

    @Attribute(.unique) public var id: UUID
    public var imagePath: String?
    public var rootNote: Note {
        get { Note(rawValue: rootRawValue) ?? .C }
        set { rootRawValue = newValue.rawValue }
    }
    
    public var rootNoteAlteration: Alteration = Alteration.natural
    public var chordType: ChordType = ChordType.major
    public var seventhType: SeventhType? = nil
    public var extendedType: ExtendedType? = nil
    public var suspendedType: SuspendedType? = nil
    public var addedType: AddedType? = nil
    public var addedAlteration: Alteration = Alteration.natural

    public var bassNote: Note?
    public var bassNoteAlteration: Alteration? = nil

    
    init(id: UUID, imagePath: String? = nil, rootNote: Note, rootNoteAlteration: Alteration = .natural, chordType: ChordType? = nil, seventhType: SeventhType? = nil, extendedType: ExtendedType? = nil, suspendedType: SuspendedType? = nil, addedType: AddedType? = nil, addedAlteration: Alteration = .natural, bassNote: Note? = nil, bassNoteAlteration: Alteration? = nil) {
        self.id = id
        self.imagePath = imagePath
        self.rootRawValue = rootNote.rawValue
        self.rootNote = rootNote
        
        self.rootNoteAlteration = rootNoteAlteration
        
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
    
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Optional: for human-readable JSON
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Error encoding user to JSON: \(error)")
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case imagePath = "image_path"
        case rootNote = "root_note"
        case rootNoteAlteration = "root_note_alteration"
        case chordType = "chord_type"
        case seventhType = "seventh_type"
        case extendedType = "extended_type"
        case suspendedType = "suspended_type"
        case addedType = "added_type"
        case addedAlteration  = "added_alteration"
        case bassNote = "bass_note"
        case bassNoteAlteration = "bass_note_alteration"
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rootNote = try container.decode(Note.self, forKey: CodingKeys.rootNote)
        
        self.rootRawValue = rootNote.rawValue

        self.id = try container.decode(UUID.self, forKey: .id)
        
        self.imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
      
        self.rootNote = rootNote
        self.rootNoteAlteration = try container.decode(Alteration.self, forKey: .rootNoteAlteration)
        self.chordType = try container.decode(ChordType.self, forKey: .chordType)
        
        self.seventhType = try container.decodeIfPresent(SeventhType.self, forKey: .seventhType)
        self.extendedType = try container.decodeIfPresent(ExtendedType.self, forKey: .extendedType)
        self.suspendedType = try container.decodeIfPresent(SuspendedType.self, forKey: .suspendedType)
        self.addedType = try container.decodeIfPresent(AddedType.self, forKey: .addedType)
        
        self.addedAlteration = try container.decode(Alteration.self, forKey: .addedAlteration)
        
        self.bassNote = try container.decodeIfPresent(Note.self, forKey: .bassNote)        
        self.bassNoteAlteration = try container.decodeIfPresent(Alteration.self, forKey: .bassNoteAlteration)

    }

    // Required for encoding (Model -> JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rootNote, forKey: .rootNote)
        try container.encode(rootNoteAlteration, forKey: .rootNoteAlteration)
        try container.encode(chordType, forKey: .chordType)

        try container.encode(seventhType, forKey: .seventhType)
        try container.encode(extendedType, forKey: .extendedType)
        try container.encode(suspendedType, forKey: .suspendedType)
        try container.encode(addedType, forKey: .addedType)
        try container.encode(addedAlteration, forKey: .addedAlteration)

        try container.encode(bassNote, forKey: .bassNote)
        try container.encode(bassNoteAlteration, forKey: .bassNoteAlteration)

        
        try container.encode(addedAlteration, forKey: .addedAlteration)
    }
    
    func copy() -> Chord {
        return try! JSONDecoder().decode(Chord.self, from: JSONEncoder().encode(self))
    }
    
    static func < (lhs: Chord, rhs: Chord) -> Bool {
        let sameRoot = lhs.rootNote == rhs.rootNote
        
        if (!sameRoot) {
            return lhs.rootRawValue < rhs.rootRawValue
        }
        
        let sameRootAlteration = lhs.rootNoteAlteration == rhs.rootNoteAlteration
        
        if (!sameRootAlteration) {
            return lhs.rootNoteAlteration < rhs.rootNoteAlteration
        }

        let sameChordType = lhs.chordType == rhs.chordType
        
        if (!sameChordType) {
            return lhs.chordType < rhs.chordType
        }

        let sameSeventhType = lhs.seventhType == rhs.seventhType
        
        if (!sameSeventhType) {
            if let lhsSeventhType = lhs.seventhType, let rhsSeventhType = rhs.seventhType {
                return lhsSeventhType < rhsSeventhType
            }
        }
        
        let sameExtendedType = lhs.extendedType == rhs.extendedType
        
        if (!sameExtendedType) {
            if let lhsExtendedType = lhs.extendedType, let rhsExtendedType = rhs.extendedType {
                return lhsExtendedType < rhsExtendedType
            }
        }
        
        let sameSuspendedType = lhs.suspendedType == rhs.suspendedType
        
        if (!sameSuspendedType) {
            if lhs.suspendedType == nil && rhs.suspendedType != nil {
                return true
            }
            
            if let lhsSuspendedType = lhs.suspendedType, let rhsSuspendedType = rhs.suspendedType {
                return lhsSuspendedType < rhsSuspendedType
            }
        }
        
        let sameAddedType = lhs.addedType == rhs.addedType
        
        if (!sameAddedType) {
            if let lhsAddedType = lhs.addedType, let rhsAddedType = rhs.addedType {
                return lhsAddedType < rhsAddedType
            }
        }
        
        
        let sameAddedAlteration = lhs.addedAlteration == rhs.addedAlteration
        
        if (!sameAddedAlteration) {
            return lhs.addedAlteration < rhs.addedAlteration
        }

        let sameBassNoteType = lhs.bassNoteAlteration == rhs.bassNoteAlteration
        
        if (!sameBassNoteType) {
            if let lhsBassNote = lhs.bassNote, let rhsBassNote = rhs.bassNote {
                return lhsBassNote < rhsBassNote

            }
        }
        
        
        let sameBassNoteAlteration = lhs.bassNoteAlteration == rhs.bassNoteAlteration
        
        if (!sameBassNoteAlteration) {
            if let lhsBassNoteAlteration = lhs.bassNoteAlteration, let rhsBassNoteAlteration = rhs.bassNoteAlteration {
                return lhsBassNoteAlteration < rhsBassNoteAlteration
            }
        }
        
        
        return false
    }

    static func == (lhs: Chord, rhs: Chord) -> Bool {
        let sameRoot = lhs.rootNote == rhs.rootNote

        if (!sameRoot) {
            return sameRoot
        }

        let sameRootAlteration = lhs.rootNoteAlteration == rhs.rootNoteAlteration
        
        if (!sameRootAlteration) {
            return sameRootAlteration
        }
        
        let sameChordType = lhs.chordType == rhs.chordType
        
        if (!sameChordType) {
            return lhs.chordType == rhs.chordType
        }
        
        let sameSeventhType = lhs.seventhType == rhs.seventhType
        
        if (!sameSeventhType) {
            if let lhsSeventhType = lhs.seventhType, let rhsSeventhType = rhs.seventhType {
                return lhsSeventhType == rhsSeventhType
            }
        }
        
        let sameExtendedType = lhs.extendedType == rhs.extendedType
        
        if (!sameExtendedType) {
            if let lhsExtendedType = lhs.extendedType, let rhsExtendedType = rhs.extendedType {
                return lhsExtendedType == rhsExtendedType
            }
        }
        
        let sameSuspendedType = lhs.suspendedType == rhs.suspendedType
        
        if (!sameSuspendedType) {
            if lhs.suspendedType == nil && rhs.suspendedType != nil {
                return true
            }
            
            if let lhsSuspendedType = lhs.suspendedType, let rhsSuspendedType = rhs.suspendedType {
                return lhsSuspendedType == rhsSuspendedType
            }
        }
        
        let sameAddedType = lhs.addedType == rhs.addedType
        
        if (!sameAddedType) {
            if let lhsAddedType = lhs.addedType, let rhsAddedType = rhs.addedType {
                return lhsAddedType == rhsAddedType
            }
        }
        
        
        let sameAddedAlteration = lhs.addedAlteration == rhs.addedAlteration
        
        if (!sameAddedAlteration) {
            return lhs.addedAlteration == rhs.addedAlteration
        }

        let sameBassNoteType = lhs.bassNoteAlteration == rhs.bassNoteAlteration
        
        if (!sameBassNoteType) {
            if let lhsBassNote = lhs.bassNote, let rhsBassNote = rhs.bassNote {
                return lhsBassNote == rhsBassNote

            }
        }
        
        
        let sameBassNoteAlteration = lhs.bassNoteAlteration == rhs.bassNoteAlteration
        
        if (!sameBassNoteAlteration) {
            if let lhsBassNoteAlteration = lhs.bassNoteAlteration, let rhsBassNoteAlteration = rhs.bassNoteAlteration {
                return lhsBassNoteAlteration == rhsBassNoteAlteration
            }
        }
        
        return true
    }
}

enum ChordType: String, CaseIterable, Identifiable, Codable, Comparable {
    case major
    case minor
    case seventh
    case diminished
    case augmented
    case power
    
    var id: String { String(describing: self) }
    
    static func < (lhs: ChordType, rhs: ChordType) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum SeventhType: String, CaseIterable, Identifiable, Codable, Comparable {
    case major
    case minor
    case dominant
    case halfDimished

    var id: String { String(describing: self) }

    static func < (lhs: SeventhType, rhs: SeventhType) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum ExtendedType: String, CaseIterable, Identifiable, Codable, Comparable {
    case ninth
    case eleventh
    case thirteenth
    
    var id: String { String(describing: self) }
    
    static func < (lhs: ExtendedType, rhs: ExtendedType) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum Alteration: String, CaseIterable, Identifiable, Codable, Comparable {
    case natural
    case flat
    case sharp
    
    var id: String { String(describing: self) }

    static func < (lhs: Alteration, rhs: Alteration) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum SuspendedType: String, CaseIterable, Identifiable, Codable, Comparable {
    case second
    case fourth
    
    var id: String { String(describing: self) }
    
    static func < (lhs: SuspendedType, rhs: SuspendedType) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum AddedType: String, CaseIterable, Identifiable, Codable, Comparable {
    case second
    case ninth
    
    var id: String { String(describing: self) }
    
    static func < (lhs: AddedType, rhs: AddedType) -> Bool {
        let allCases = Self.allCases
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

enum Note: String, CaseIterable, Identifiable, Codable, Comparable {
    static func < (lhs: Note, rhs: Note) -> Bool {
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
