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
    public var id: UUID
    public var name: String
    public var shortName: String
    public var imagePath: String?
    public var root: String?
    public var chordType: ChordType? = ChordType.major
    public var altered: Bool = false
    public var alteration: Int?
    public var alterationType: AlterationType?
    
    public var suspended: Bool = false
    public var suspendedBy: Int?
    public var bassNote: String?

    init(id: UUID, name: String, shortName: String, imagePath: String?) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.imagePath = imagePath
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

enum AlterationType: String, CaseIterable, Identifiable, Codable {
    case flat
    case sharp
    case natural
    
    var id: String { self.rawValue }

}
