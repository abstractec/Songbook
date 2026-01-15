//
//  SongPerformance.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import Foundation
import SwiftData

@Model
public final class SongPerformance: Identifiable {
    @Attribute(.unique) public var id: UUID
    var name: String
    var instrument: Instrument? = nil
    var instrumentConfiguration: InstrumentConfiguration? = nil
    var song: Song
    var position: Int? = 0

    init(id: UUID, name: String, song: Song, instrument: Instrument? = nil, instrumentConfiguration: InstrumentConfiguration? = nil, position: Int? = nil) {
        self.id = id
        self.name = name
        self.song = song
        self.instrument = instrument
        self.instrumentConfiguration = instrumentConfiguration
        self.position = position
    }
}
