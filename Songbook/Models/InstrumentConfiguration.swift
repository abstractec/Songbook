//
//  InstrumentConfiguration.swift
//  Songbook
//
//  Created by John Haselden on 12/01/2026.
//

import Foundation
import SwiftData

@Model
final class InstrumentConfiguration: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var capoPosition: Int?
    
    public init(id: UUID, name: String, capoPosition: Int? = nil) {
        self.id = id
        self.name = name
        self.capoPosition = capoPosition
    }
}
