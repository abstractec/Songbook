//
//  SongRenderer.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

protocol SongRenderer {
    func render(song: Song, transposedBy: Int?) -> String
}
