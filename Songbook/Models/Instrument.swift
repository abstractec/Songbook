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
    public var configurations: [InstrumentConfiguration] = []
    
    public init(id: UUID = .init(), name: String, strings: [InstrumentString] = [], configurations: [InstrumentConfiguration] = []) {
        self.id = id
        self.name = name
        self.strings = strings
        self.configurations = configurations
    }
    
    func copy() -> Instrument {
        return Instrument(id: UUID(), name: name, strings: strings, configurations: configurations)
    }
    
    var defaultConfig: InstrumentConfiguration {
        return InstrumentConfiguration(id: UUID(), name: "Default")
    }
}


