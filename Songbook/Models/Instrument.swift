//
//  Instrument.swift
//  Songbook
//
//  Created by John Haselden on 06/01/2026.
//

import Foundation
import SwiftData

@Model
final class Instrument: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var strings: [InstrumentString] = []
    public var capo: Int?
    
    public init(id: UUID = .init(), name: String, strings: [InstrumentString] = [], capo: Int? = nil) {
        self.id = id
        self.name = name
        self.strings = strings
        self.capo = capo
    }
    
    func copy() -> Instrument {
        return Instrument(id: UUID(), name: name, strings: strings, capo: capo)
    }
}


