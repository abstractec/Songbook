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
    private var modelContext: ModelContext?
    var section: Section
    var phrase: Phrase?
    let chordRenderer: ChordRenderer = PlainTextChordRenderer()
    
    var lyric: String = ""

    var lyrics: [String] = []
    var chordSequence: [String] = []
    var chordSequenceRepeatCount: Int = 1
    var chordSequenceTiming: [Int] = []
    
    var renderedPhrase: String = ""
    var selectedSpace: Int? = nil
    var currentLyricStep: Int = 0
    
    var phraseLength = 31
    
    init(section: Section, phrase: Phrase? = nil, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        self.phrase = phrase
        
        let chordRenderer = PlainTextChordRenderer()
        
        // our max length is 31 (ish) on an ipad
        if let lyric = self.phrase?.lyric.text {
            self.lyric = lyric
            self.lyrics = self.updateDisplayLyrics(lyric)
        }

        for step in phrase?.chordSequence.sequence ?? [] {
            let shortName = chordRenderer.renderShortName(chord: step.chord)
            
            chordSequence.append(shortName)
            chordSequenceTiming.append(step.step)
        }
        
        updateChordSequence()
    }
    
    func updateLyric(_ lyric: String) {
        self.lyric = lyric
        self.lyrics = self.updateDisplayLyrics(lyric)
        
        self.phrase?.lyric.text = self.lyric

        updateChordSequence()
        
    }
    
    private func updateDisplayLyrics(_ lyrics: String) -> [String] {
        var lyrics: [String]  = []
        if lyric.count > phraseLength {
            lyrics = lyric.split(by: phraseLength)
        } else {
            lyrics = [lyric]
        }
        
        updateChordSequence()
        
        return lyrics
    }
    
    func setChord(_ chord: Chord, atPosition position: Int) {
        if (phrase?.chordSequence == nil) {
            phrase?.chordSequence = ChordSequence(id: UUID(), sequence: [])
        }
        
        let step = ChordSequenceStep(id: UUID(), chord: chord, step: position)
        
        phrase?.chordSequence.sequence.append(step)
        
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
            let renderer = PlainTextSongRenderer()
            self.renderedPhrase = renderer.render(phrase: mainPhrase)
        }
    }
    
    func savePhrase() {
        // save or update
        if let phrase = self.phrase {
            if phrase.sections.count == 0 {
                phrase.sections = [self.section]
                phrase.position = self.section.phrases.count - 1
                
                modelContext?.insert(phrase)
                
                if let modelContext = self.modelContext {
                    do {
                        try modelContext.save()
                    } catch {
                        print("we failed to save the phrase")
                    }
                }
            }
            
            phrase.lyric.text = lyric
            
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

}
