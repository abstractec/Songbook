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
                
        renderedPhrase.append(contentsOf: render(chordSequence: phrase.chordSequence))
        
        if let repeatCount = phrase.chordSequenceRepeatCount {
            renderedPhrase.append(" x \(repeatCount)")
        }
        renderedPhrase.append("\n")
        
        renderedPhrase.append(phrase.lyric.text)
        
        return renderedPhrase
    }
    
    private func render(chordSequence: ChordSequence) -> String {
        var renderedChordSequence = ""
        
        var max = 0
        
        for sequence in chordSequence.sequence {
            if sequence.step > max {
                max = sequence.step
            }
        }
                
        max += 1
        var i = 0
        
        for(_) in 0..<max {
            let steps = chordSequence.sequence.filter({ $0.step == i})
            
            if (steps.isEmpty) {
                renderedChordSequence.append(" ")
            }
            
            for step in steps {
                // should only be one, but to be safe
                print("got step \(step.chord.shortName) at \(i)")
                
                let chordSize = step.chord.shortName.count
                renderedChordSequence.append(step.chord.shortName)
                i += chordSize - 1
            }
            
            i += 1
        }
                
        return renderedChordSequence
    }
    
    func formatOrdinal(number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)th" // Fallback
    }
}
