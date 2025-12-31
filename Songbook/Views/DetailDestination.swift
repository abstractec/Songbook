//
//  DetailDestination.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

enum DetailDestination: Hashable {
    case newSong
    case newSection(song: Song)
    case newPhrase(section: Section)
    
    case viewSong(song: Song)
}
