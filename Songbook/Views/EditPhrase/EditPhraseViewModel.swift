//
//  EditPhraseViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

@Observable
class EditPhraseViewModel {
    var phrase: Phrase?
    
    var lyric: String = ""
    var lyrics: [String] = []
    var availableChords: [Chord] = []
    var chordSequence: [String] = []
    var chordSequenceRepeatCount: Int = 1
    var chordSequenceTiming: [Int] = []
    
    var renderedPhrase: String = ""
    var selectedSpace: Int? = nil
    var currentLyricStep: Int = 0
    
    var phraseLength = 31

    init(phrase: Phrase? = nil) {
        self.phrase = phrase
        
        // our max length is 31 (ish) on an ipad
        if let lyric = self.phrase?.lyric?.text {
            if lyric.count > phraseLength {
                lyrics = lyric.split(by: phraseLength)
            } else {
                lyrics = [lyric]
            }
            self.lyric = lyric
        }
        
        for chord in (phrase?.chordSequence?.chords ?? []) {
            chordSequence.append(chord.shortName)
        }
        
        for timing in (phrase?.chordSequence?.spacing ?? []) {
            chordSequenceTiming.append(timing)
        }
        
        updateChordSequence()
    }
    
    func addChord(name: String, shortName: String) {
        let chord = Chord(id: UUID(), name: name, shortName: shortName, imagePath: nil)
        availableChords.append(chord)
    }
    
    func setChord(_ chord: Chord, atPosition position: Int) {
        if let chordSequence = phrase?.chordSequence {
            chordSequence.chords.append(chord)
        } else {
            print("where's this gone?")
        }
        
        phrase?.chordSequence?.spacing.append(position)
        
        if let index = availableChords.firstIndex(of: chord) {
            availableChords.remove(at: index)
        }
        
        updateChordSequence()
    }
    
    func chordForPosition(_ position: Int) -> Chord? {
        var chord: Chord? = nil
        for i in 0..<(phrase?.chordSequence?.spacing.count ?? 0) {
            if (phrase?.chordSequence?.spacing[i] ?? 0) == position {
                chord = phrase?.chordSequence?.chords[i]
            }
            
        }
        return chord
    }
    
    func removeChordAt(_ position: Int) {
        for i in 0..<(phrase?.chordSequence?.spacing.count ?? 0) {
            if (i < phrase?.chordSequence?.spacing.count ?? 0) {
                if (phrase?.chordSequence?.spacing[i] ?? 0) == position {
                    if let chord = phrase?.chordSequence?.chords[i] {
                        availableChords.append(chord)
                    }
                    
                    phrase?.chordSequence?.chords.remove(at: i)
                    phrase?.chordSequence?.spacing.remove(at: i)
                }
            }
        }
        
        updateChordSequence()
    }
    
    func startStepForIndex(_ index: Int) -> Int {
        return index * phraseLength
        
    }
    
    private func updateChordSequence() {
       
        if let mainPhrase = self.phrase {
            let lyric = Lyric(id: UUID(), text: self.lyric)
            let phrase = Phrase(id: UUID(), lyric: lyric, chordSequence: mainPhrase.chordSequence)
           
            let renderer = PlainTextSongRenderer()
            self.renderedPhrase = renderer.render(phrase: phrase)
        }
    }
}
