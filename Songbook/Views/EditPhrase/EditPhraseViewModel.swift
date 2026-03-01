//
//  EditPhraseViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class EditPhraseViewModel {
    var modelContext: ModelContext?
    var section: Section
    var phrase: Phrase?
    let chordRenderer: ChordRenderer = PlainTextChordRenderer()
    
    var lyric: String = ""
    var repeats: String = "" 

    var lyrics: [String] = []
    var chordSequence: [String] = []
    var chordSequenceRepeatCount: Int = 1
    var chordSequenceTiming: [Int] = []
    
    var renderedPhrase: String = ""
    var selectedSpace: Int? = nil
    var currentLyricStep: Int = 0
    
    var phraseLength = 28
    
    init(section: Section, phrase: Phrase? = nil, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        self.phrase = phrase
        
        let chordRenderer = PlainTextChordRenderer()
        
        // our max length is 31 (ish) on an ipad
        if let lyric = self.phrase?.lyric {
            self.lyric = lyric.text
            self.lyrics = self.updateDisplayLyrics(lyric.text)
        }

        for step in phrase?.chordSequence.sequence ?? [] {
            let shortName = chordRenderer.renderShortName(chord: step.chord)
            
            chordSequence.append(shortName)
            chordSequenceTiming.append(step.step)
        }
        
        if let repeats = phrase?.repeats {
            self.repeats = String(repeats)
        }
        
        updateChordSequence()
    }
    
    func updateLyric(_ lyric: String) {
        self.lyric = lyric

        if let lyric = self.phrase?.lyric {
            lyric.text = self.lyric
        } else {
            self.phrase?.lyric = Lyric(text: lyric)
        }
        
        self.lyrics = self.updateDisplayLyrics(lyric)

        updateChordSequence()
    }
    
    func updateRepeats(_ repeats: String) {
        if let int = Int(repeats) {
            self.phrase?.repeats = int
            self.repeats = String(repeats)
        } else {
            print("repeat doesn't seem to be an integer")
        }
    }
    
    private func updateDisplayLyrics(_ lyric: String) -> [String] {
        var lyrics: [String]  = []
                
//        if let position = findLastWhitespace(before: phraseLength, in: lyric) {
//            lyrics = [
//                String(lyric[..<position]),
//                String(lyric[position...])
//            ]
//        
//            // TODO: iterate over the last lyric until everything is within the parameters
//            
//            if lyrics[1].lengthOfBytes(using: .utf8) > phraseLength {
//                if let position = findLastWhitespace(before: phraseLength, in: lyrics[1]) {
//                    let newLyrics = [
//                        lyrics[0],
//                        String(lyrics[1][..<position]),
//                        String(lyrics[1][position...])
//                    ]
//                    
//                    lyrics = newLyrics
//                }
//            }
//        } else {
//            lyrics = [lyric]
//        }
        
        updateChordSequence()
        
        return splitLyric(lyric)
    }
    
    private func splitLyric(_ lyric: String) -> [String] {
        if (lyric.count > phraseLength) {
            if let position = findLastWhitespace(before: phraseLength, in: lyric) {
                var lyrics: [String] = []
                let first = String(lyric[..<position])
                let second = String(lyric[position...])
                
                lyrics.append(first)
                
                if second.count > phraseLength {
                    lyrics.append(contentsOf: splitLyric(second))
                } else {
                    lyrics.append(second)
                }
                
                return lyrics
            }
        }
            
        return [lyric]
    }
    
    func setChord(_ chord: Chord, atPosition position: Int?) {
        if (phrase?.chordSequence == nil) {
            phrase?.chordSequence = ChordSequence(id: UUID(), sequence: [])
        }

        let steps = phrase?.chordSequence.sequence.map { $0.step }

        if let position = position {
            // what am I aiming for?
            let stepsMax = steps?.max() ?? 0
            let stepsCount = steps?.count ?? 0
            
            let targetStepPosition = max(stepsMax, stepsCount, position)
            
            let step = ChordSequenceStep(id: UUID(), chord: chord, step: targetStepPosition)
            phrase?.chordSequence.sequence.append(step)
        } else {
            let step = ChordSequenceStep(id: UUID(), chord: chord, step: (steps?.max() ?? 0) + 1)
            phrase?.chordSequence.sequence.append(step)
        }
        
        updateChordSequence()
    }
    
    func chordForPosition(_ position: Int) -> Chord? {
        var chord: Chord? = nil

        for step in phrase?.chordSequence.sequence ?? [] {
            if step.step == position {
                chord = step.chord
            }
        }
                        
        return chord
    }
    
    func removeChordAt(_ position: Int) {
        phrase?.chordSequence.sequence.removeAll { $0.step == position }
        updateChordSequence()
    }
    
    func startStepForIndex(_ index: Int) -> Int {
        return index * phraseLength
        
    }
    
    func updateChordSequence() {
        if let mainPhrase = self.phrase {
            print(mainPhrase.lyric)
            let renderer = PlainTextSongRenderer()
            self.renderedPhrase = renderer.render(phrase: mainPhrase)
        }
    }
    
    func hasLyrics() -> Bool {
        return lyric.count > 0
    }
    
    func savePhrase() {
        // save or update
        if let phrase = self.phrase {
            phrase.section = section
            phrase.position = self.section.phrases.count - 1
            section.phrases.append(phrase)
                
            if let modelContext = self.modelContext {
                do {
                    try modelContext.save()
                } catch {
                    print("we failed to save the phrase")
                }
            }
            
            phrase.lyric?.text = lyric
            
        }
    }
    
    func shortName(for chord: Chord?) -> String {
        if let chord = chord {
            return chordRenderer.renderShortName(chord: chord)
        } else {
            return ""
        }
    }
    
    func name(for chord: Chord?) -> String {
        if let chord = chord {
            return chordRenderer.render(chord: chord)
        } else {
            return ""
        }
    }

    func shortName(for binding: Binding<Chord?>) -> Binding<String> {
        if let chord = binding.wrappedValue {
            return Binding<String>.constant(chordRenderer.renderShortName(chord: chord))
        } else {
            return Binding<String>.constant("")
        }
    }

    func name(for binding: Binding<Chord?>) -> Binding<String> {
        if let chord = binding.wrappedValue {
            return Binding<String>.constant(chordRenderer.render(chord: chord))
        } else {
            return Binding<String>.constant("")
        }
    }
    
    func delete(chordSequenceStep: ChordSequenceStep) {
        if let index = phrase?.chordSequence.sequence.firstIndex(of: chordSequenceStep) {
            phrase?.chordSequence.sequence.remove(at: index)
        }
        
        updateChordSequence()
    }
    
    func increasePreLyrics() {
        self.updateLyric(" " + lyric)
    }

    func decreasePreLyrics() {
        if (lyric.first == " ") {
            lyric.removeFirst()
            self.updateLyric(lyric)
        }
    }

    func increasePostLyrics() {
        self.updateLyric(lyric + " ")
    }

    func decreasePostLyrics() {
        if (lyric.last == " ") {
            lyric.removeLast()
            self.updateLyric(lyric)
        }
    }

    private func findLastWhitespace(before characterLimit: Int, in string: String) -> String.Index? {
        guard string.count >= characterLimit else {
            return nil
        }

        guard let limitIndex = string.index(string.startIndex, offsetBy: characterLimit, limitedBy: string.endIndex) else {
            return nil
        }

        let searchRange = string.startIndex..<limitIndex

        if let range = string.range(of: " ", options: .backwards, range: searchRange) {
            return range.lowerBound
        }

        return nil
    }
}
