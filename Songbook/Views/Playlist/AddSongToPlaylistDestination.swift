//
//  AddSongToPlaylistDestination.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import Foundation

enum AddSongToPlaylistDestination: Hashable {
    case addInstrument(song: Song)
    case saved
}
