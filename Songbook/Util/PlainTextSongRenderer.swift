//
//  PlainTextSongRenderer.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

class PlainTextSongRenderer: SongRenderer {
    func render(song: Song, transposedBy semitones: Int = 0) -> String {
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
        
        if (extraNewline) {
            renderedSong.append("\n")
        }

        for section in song.sections {
            renderedSong.append(contentsOf: render(section: section, transposedBy: semitones))
        }
        
        return renderedSong
    }
    
    public func render(section: Section, transposedBy semitones: Int = 0) -> String {
        var renderedSection = ""
        
        renderedSection.append(section.name)
        renderedSection.append("\n\n")
        
        for phrase in section.phrases.sorted(by: { $0.position < $1.position }) {
            renderedSection.append(contentsOf: render(phrase: phrase, transposedBy: semitones))
            renderedSection.append("\n")
        }

        return renderedSection
    }
    
    func render(phrase: Phrase, transposedBy semitones: Int = 0) -> String {
        var chordLine = ""
        var lyricLine = ""
        
        let chordRenderer = PlainTextChordRenderer()
        let basicTransposer = BasicTransposer()
        
        let workingPhrase = basicTransposer.transpose(phrase: phrase, by: semitones)
        
        var workingLyrics = ""
                
        if let lyrics = phrase.lyric {
            workingLyrics = lyrics.text
        }
        
        let sequence = workingPhrase.chordSequence.sequence.sorted(by: { $0.step < $1.step})
        
        var chordOffset = 0
        var sequenceOffset = 0
        
        if workingLyrics.count == 0 {
            // just print out the chords
            for step in sequence {
                chordLine.append(contentsOf: chordRenderer.renderShortName(chord: step.chord))
                chordLine.append(" ")
            }
        } else {
            var remainingChords = sequence.map { $0.chord }.count
            
            for (i) in 0..<workingLyrics.count {
                // do I have a sequence at this step?
                if let nextStep = sequence.filter({$0.step == i}).first {
                    let chord = nextStep.chord.copy()
                    remainingChords -= 1

                    let shortName = chordRenderer.renderShortName(chord: chord)
                    chordLine.append(shortName)
                    
                    // now, the checks
                    
                    // if we've got a single character shortname, then we should be all gravy
                    
                    // if our chord is greater than one character in length, we need to check if we have to re-align our lyrics to match what we're doing
                    
                    // if our next chord step is not going to be rendered correctly because of this chord, then do the offset stuff
                    
                    if let nextStepAfter = sequence.filter({$0.step > i}).first {
                        if (nextStepAfter.step < i + shortName.count) {
                            if (shortName.count > 1) {
                                sequenceOffset = shortName.count
                            } else {
                                sequenceOffset = 1 - shortName.count
                            }
                        } else {
                            if (shortName.count > 1) {
                                chordOffset = shortName.count - 1
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
                    if let lyric = phrase.lyric {
                        let index = lyric.text.index(lyric.text.startIndex, offsetBy: i)
                        
                        lyricLine.append(lyric.text[index])
                    }
                }
                
                if (sequenceOffset > 0) {
                    for (_) in 0..<sequenceOffset-1 {
                        lyricLine.append(" ")
                    }
                    
                    sequenceOffset = 0
                }
                
            }
            
            if remainingChords > 0 {
                for (i) in remainingChords..<sequence.count {
                    let step = sequence[i]
                    chordLine.append("\(chordRenderer.renderShortName(chord: step.chord)) ")
                }
            }
            
        }

        if phrase.repeats > 1 {
            var output = ""
            
            var paddedString = chordLine.padding(toLength: lyricLine.count, withPad: " ", startingAt: 0)

            if (paddedString == "") {
                paddedString = "\(chordLine) x\(phrase.repeats)"
            } else {
                paddedString += " x\(phrase.repeats)"
            }

            output.append("\(paddedString)\n\(lyricLine)")
            
            return output
        } else {
            return "\(chordLine)\n\(lyricLine)"
        }
    }
    
    private func render(chordSequence: ChordSequence) -> String {
        var renderedChordSequence = ""
        let chordRenderer = PlainTextChordRenderer()

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
                let shortName = chordRenderer.renderShortName(chord: step.chord)
                // should only be one, but to be safe
                let chordSize = shortName.count
                renderedChordSequence.append(shortName)
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
