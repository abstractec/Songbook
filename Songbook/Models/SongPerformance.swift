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
    var instrument: Instrument? = nil
    var instrumentConfiguration: InstrumentConfiguration? = nil
    
    
    var song: Song
    var position: Int

    init(id: UUID, song: Song, instrument: Instrument? = nil, instrumentConfiguration: InstrumentConfiguration? = nil, position: Int) {
        self.id = id
        self.song = song
        self.instrument = instrument
        self.instrumentConfiguration = instrumentConfiguration
        self.position = position
    }
}
