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
    public var name: String
    public var instrument: Instrument? = nil

    var songPerformances: [SongPerformance]

    init(id: UUID, name: String, songPerformances: [SongPerformance]) {
        self.id = id
        self.name = name
        self.songPerformances = songPerformances
    }
}
