//
//  EditPhraseViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation
import SwiftData

@Observable
class EditPhraseViewModel {
    private var modelContext: ModelContext?
    var section: Section
    var phrase: Phrase?
    
    var lyric: String = "" {
        didSet(oldLyrics) {
            phrase?.lyric.text = self.lyric
            self.lyrics = updateDisplayLyrics(self.lyric)
        }
    }
    var lyrics: [String] = []
    var availableChords: [Chord] = []
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
        
        // our max length is 31 (ish) on an ipad
        if let lyric = self.phrase?.lyric.text {
            self.lyrics = self.updateDisplayLyrics(lyric)
            self.lyric = lyric
        }
        
        let chords = try! modelContext?.fetch(FetchDescriptor<Chord>())
        
        for chord in chords ?? [] {
            availableChords.append(chord)
        }

        for step in phrase?.chordSequence.sequence ?? [] {
            
            if !availableChords.contains(step.chord) {
                availableChords.append(step.chord)
            }

            
            chordSequence.append(step.chord.shortName)
            chordSequenceTiming.append(step.step)
        }
                
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
    
    func addChord(name: String, shortName: String) {
        let chord = Chord(id: UUID(), name: name, shortName: shortName, imagePath: nil)

        if let modelContext = self.modelContext {
                
            modelContext.insert(chord)
            
            do {
                try modelContext.save()
            } catch {
                print("we failed to save the chord")
            }
        }
        availableChords.append(chord)
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
    
    private func updateChordSequence() {
       
        if let mainPhrase = self.phrase {
            let renderer = PlainTextSongRenderer()
            self.renderedPhrase = renderer.render(phrase: mainPhrase)
        }
    }
    
    func savePhrase() {
        // save or update
        if let phrase = self.phrase {
            phrase.position = self.section.phrases.count
            self.section.phrases.append(phrase)
        }
        
    }
}
