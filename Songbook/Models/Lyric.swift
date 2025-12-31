//
//  Lyric.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
final class Lyric: Identifiable {
    public var id: UUID
    public var text: String
    
    public init(id: UUID = .init(), text: String) {
        self.id = id
        self.text = text
    }
}
