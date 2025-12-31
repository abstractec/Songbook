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
    
    init(id: UUID, name: String, shortName: String, imagePath: String?) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.imagePath = imagePath
    }
}
