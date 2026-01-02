//
//  ChordRenderer.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation

protocol ChordRenderer {
    func render(chord: Chord) -> String
    func renderShortName(chord: Chord) -> String
}
