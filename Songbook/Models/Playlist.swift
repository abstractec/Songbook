//
//  Playlist.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Model
public final class Playlist: Identifiable {
    @Attribute(.unique) public var id: UUID
    public var name: String
    var songPerformances: [SongPerformance]

    init(id: UUID, name: String, songPerformances: [SongPerformance]) {
        self.id = id
        self.name = name
        self.songPerformances = songPerformances
    }
}
