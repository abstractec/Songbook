//
//  SongListViewModel.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import SwiftData
import CoreData

@Observable
class SongListViewModel {
    private var modelContext: ModelContext?
    var isImporting: Bool = false

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        if let modelContext = self.modelContext {
            let dataRepository = DataRepository(modelContext: modelContext)
            let tmpSongs = dataRepository.loadItems(fetchDescriptor: FetchDescriptor<Song>())
            self.songs = tmpSongs.sorted(by: {$0.title < $1.title})
        }
    }
    
    var songs: [Song] = []
    
    var sortOrder: SingListSort = .title {
        didSet {
            do {
                let tmpSongs = try modelContext?.fetch(FetchDescriptor<Song>()) ?? []
                self.songs = tmpSongs.sorted(by: {$0.title < $1.title})
            } catch {
                // something went awry
                print("can't load songs")
            }
        }
    }
    
    func delete(song: Song) {
        
        modelContext?.delete(song)
    }
    
    func importSong(from url: URL) {
        isImporting = true
        
        guard url.startAccessingSecurityScopedResource() else {
                print("Permission denied")
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedSong = try decoder.decode(Song.self, from: data)
                
                let newSong = Song(id: decodedSong.id, title: decodedSong.title, sections: [], key: decodedSong.key, artist: decodedSong.artist)
                modelContext?.insert(newSong)
                
                for section in decodedSong.sections {
                    let newSection = Section(id: section.id, name: section.name, phrases: [], position: section.position)
                    newSong.sections.append(newSection)
                    newSection.song = newSong
                    

                    for phrase in section.phrases {
                        let newPhrase = Phrase(id: phrase.id, chordSequence: nil, position: phrase.position, repeats: phrase.repeats)

                        if let oldLyric = phrase.lyric {
                            let newLyric = Lyric(id: oldLyric.id, text: oldLyric.text)
                                                        
                            newPhrase.lyric = newLyric
                            
                            newSection.phrases.append(newPhrase)
                            newPhrase.section = newSection
                        }

                        if let newSequence = try handleSequence(phrase.chordSequence) {
                            newPhrase.chordSequence = newSequence
                        }
                    }
                }
                
                print("we got one!")
            } catch let error as NSError {
                print("Decoding error: \(error.localizedDescription)")
                
                if let detailedErrors = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
                    for subError in detailedErrors {
                        print("Validation Error: \(subError.localizedDescription)")
                        print("Failed Key: \(subError.userInfo[NSValidationKeyErrorKey] ?? "Unknown")")
                    }
                }
            }
    }
    
    private func handleSequence(_ originalSequence: ChordSequence) throws -> ChordSequence? {
        var steps: [ChordSequenceStep] = []

        for sequence in originalSequence.sequence {
            let importChord = sequence.chord
            let chords = try modelContext?.fetch(FetchDescriptor<Chord>());

            if let chords = chords {
                
                var found = false
                var foundChord = importChord

                for dbChord in chords {
                    
                    if (dbChord == foundChord) {
                        found = true
                        foundChord = dbChord
                    }
                }
                
                if !found {
                    modelContext?.insert(importChord)
                    foundChord = importChord
                    
                    try modelContext?.save()
                }

                let newStep = ChordSequenceStep(id: sequence.id, chord: foundChord, step: sequence.step)
                steps.append(newStep)
            }
            
        }
        
        let newSequence = ChordSequence(id: originalSequence.id, sequence: [])
        modelContext?.insert(newSequence)

        for step in steps {
            newSequence.sequence.append(step)
            step.chordSequence = newSequence
        }

        return newSequence
    }       
}

enum SingListSort: Hashable {
    case title
    case artist
    case album
}

