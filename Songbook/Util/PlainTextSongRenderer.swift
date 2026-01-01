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
        var chordLine = ""
        var lyricLine = ""
        let workingLyrics = phrase.lyric.text
        let sequence = phrase.chordSequence.sequence.sorted(by: { $0.step < $1.step})
        
        var chordOffset = 0
        var sequenceOffset = 0

        for (i) in 0..<workingLyrics.count {
            // do I have a sequence at this step?
            if let nextStep = sequence.filter({$0.step == i}).first {
                chordLine.append(nextStep.chord.shortName)

                // now, the checks
                
                // if we've got a single character shortname, then we should be all gravy
                
                // if our chord is greater than one character in length, we need to check if we have to re-align our lyrics to match what we're doing
                
                // if our next chord step is not going to be rendered correctly because of this chord, then do the offset stuff
                
                if let nextStepAfter = sequence.filter({$0.step > i}).first {
                    if (nextStepAfter.step < i + nextStep.chord.shortName.count) {
                        if (nextStep.chord.shortName.count > 1) {
                            sequenceOffset = nextStep.chord.shortName.count
//                            chordOffset = -1
                        } else {
                            sequenceOffset = 1 - nextStep.chord.shortName.count
                        }
                    } else {
                        if (nextStep.chord.shortName.count > 1) {
                            chordOffset = nextStep.chord.shortName.count - 1
                        }
                    }
                }
            } else {
                if chordOffset == 0 {
                    chordLine.append(" ")
                } else if (chordOffset < 0) {
                    chordOffset += 1
                } else if (chordOffset > 0) {
                    chordOffset -= 1
                }
            }

            if (i < workingLyrics.count) {
                let index = phrase.lyric.text.index(phrase.lyric.text.startIndex, offsetBy: i)
                
                lyricLine.append(phrase.lyric.text[index])
            }
            
            if (sequenceOffset > 0) {
                for (_) in 0..<sequenceOffset-1 {
                    lyricLine.append(" ")
                }
                
                sequenceOffset = 0
            }

        }
        
        return "\(chordLine)\n\(lyricLine)"
    }
    
 
    
    func renderOld(phrase: Phrase) -> String {
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
            let originalI = i
            let steps = chordSequence.sequence.filter({ $0.step == i})
            
            if (steps.isEmpty) {
                renderedChordSequence.append(" ")
            }
            
            for step in steps {
                // should only be one, but to be safe
                let chordSize = step.chord.shortName.count
                renderedChordSequence.append(step.chord.shortName)
                i += chordSize - 1
            }
            
            i += 1

            // here's where we need to check if we've skipped a chord
            for (j) in originalI+1..<i {
                let skippedStep = chordSequence.sequence.filter({ $0.step == j})
                if !skippedStep.isEmpty {
                    print("we missed something \(skippedStep)")
                }
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
