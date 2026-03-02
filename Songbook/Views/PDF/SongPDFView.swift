//
//  SongPDFView.swift
//  Songbook
//
//  Created by John Haselden on 02/03/2026.
//

import SwiftUI

struct SongPDFView: View {
    var song: Song
    
    var body: some View {
        VStack {
            Text(song.title)
                .font(.headline)
                               
            if let key = song.key {
                HStack {
                    Text("Key: \(key)").font(.footnote.monospaced())
                    Spacer()
                }.padding(.horizontal)
            }
            
//                    if let capo = song.capo {
//                        HStack {
//                            Text("Capo")
//                            Text(capo)
//                            Spacer()
//                        }.padding(.horizontal)
//                    }
            
            ForEach(song.sections.sorted(by: { $0.position < $1.position })) { section in
                VStack {
                    HStack(spacing:0) {
                        VStack{
                            HStack {
                                Text("[\(section.name)]").font(.footnote.monospaced())
                                Spacer()
                            }.padding(.bottom, 8)
                            
                            ForEach(section.phrases.sorted{ $0.position < $1.position }) { phrase in
                                HStack() {
                                    PhraseView(viewModel: PhraseViewModel(phrase: phrase))
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 2)
                            }
                        }
                    }
                    
                }

            }.padding()
        }
       
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let song = Song(id: UUID(), title: "Test Song", sections: [])
    let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [])
    let section2 = Section(id: UUID(), name: "Verse 2", song: song, phrases: [])

    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let gMajor = Chord(id: UUID(), rootNote: .G)
    let dMajor = Chord(id: UUID(), rootNote: .D)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 7)
    let chordSequenceStep3 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 9)
    let chordSequenceStep4 = ChordSequenceStep(id: UUID(), chord: dMajor, step: 16)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    let chordSequence2 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep3, chordSequenceStep4])

    let lyric1 = Lyric(id: UUID(), text: "I am a lyric")
    let lyric2 = Lyric(id: UUID(), text: "I am the second line")
    
    let phrase1 = Phrase(id: UUID(), chordSequence: chordSequence1)
    phrase1.lyric = lyric1
    
    let phrase2 = Phrase(id: UUID(), chordSequence: chordSequence2)
    phrase2.lyric = lyric2

    let phrase3 = Phrase(id: UUID(), chordSequence: chordSequence1)
    phrase1.lyric = lyric1
    
    let phrase4 = Phrase(id: UUID(), chordSequence: chordSequence2, repeats: 3)
    phrase2.lyric = lyric2

    section.phrases.append(phrase1)
    section.phrases.append(phrase2)
    section.phrases.append(phrase3)
    section.phrases.append(phrase4)

    song.sections.append(section)
    song.sections.append(section2)
    song.key = "C Major"

    return SongPDFView(song: song)
}
