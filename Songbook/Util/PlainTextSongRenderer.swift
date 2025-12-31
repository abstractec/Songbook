//
//  PlainTextSongRenderer.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

class PlainTextSongRenderer: SongRenderer {
    func render(song: Song) -> String {
        var renderedSong = ""
        renderedSong.append(contentsOf: song.title)
        renderedSong.append("\n")

        for _ in 0..<song.title.count {
            renderedSong.append("-")
        }
        renderedSong.append("\n")

        var extraNewline = false
        
        if let key = song.key {
            renderedSong.append("Key: \(key)\n")
            extraNewline = true
        }
        
        if let capo = song.capo {
            renderedSong.append("Capo: \(formatOrdinal(number: capo)) fret\n")
            extraNewline = true
        }

        if (extraNewline) {
            renderedSong.append("\n")
        }

        for section in song.sections {
            renderedSong.append(contentsOf: render(section: section))
        }
        
        return renderedSong
    }
    
    private func render(section: Section) -> String {
        var renderedSection = ""
        
        renderedSection.append(section.name)
        renderedSection.append("\n\n")
        
        for phrase in section.phrases {
            renderedSection.append(contentsOf: render(phrase: phrase))
            renderedSection.append("\n")
        }

        return renderedSection
    }
    
    func render(phrase: Phrase) -> String {
        var renderedPhrase = ""
                
        if let chordSequence = phrase.chordSequence {
            renderedPhrase.append(contentsOf: render(chordSequence: chordSequence))
            
            if let repeatCount = phrase.chordSequenceRepeatCount {
                renderedPhrase.append(" x \(repeatCount)")
            }
            renderedPhrase.append("\n")
        }
        
        if let lyric = phrase.lyric {
            renderedPhrase.append(lyric.text)
        }
        
        return renderedPhrase
    }
    
    private func render(chordSequence: ChordSequence) -> String {
        var renderedChordSequence = ""
        
        if var max = chordSequence.spacing.max() {
            max += 1
            var i = 0
            
            while i < max {
                if let index = chordSequence.spacing.firstIndex(of: i) {
                    let chord = chordSequence.chords[index]
                    let chordSize = chord.shortName.count
                    
                    renderedChordSequence.append(chord.shortName)
                    
                    print("renderedChordSequence: \(renderedChordSequence)")
                    i += chordSize - 1
                } else {
                    renderedChordSequence.append(" ")
                }
                
                i += 1
            }
        }
        
        
        return renderedChordSequence
    }
    
    func formatOrdinal(number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)th" // Fallback
    }
}
