//
//  Chord.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Chord: Identifiable, Codable {
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
