//
//  Transposer.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation

protocol Transposer {
    func transpose(song: Song, by semitones: Int) -> Song
    func transpose(section: Section, by semitones: Int) -> Section
    func transpose(phrase: Phrase, by semitones: Int) -> Phrase

}
