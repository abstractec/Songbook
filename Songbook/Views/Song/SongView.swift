//
//  SongView.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import SwiftUI

struct SongView: View {
    var viewModel: SongViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.song.title)
                    .font(.headline)
                
                if (viewModel.showKey) {
                    HStack {
                        Text("Key")
                        Text(viewModel.key)
                        Spacer()
                    }.padding(.horizontal)
                }

                if (viewModel.showCapo) {
                    HStack {
                        Text("Capo")
                        Text(viewModel.capo)
                        Spacer()
                    }.padding(.horizontal)
                }
                
                ForEach(viewModel.sections) { section in
                    VStack {
                        HStack(spacing:0) {
                            VStack{
                                HStack {
                                    Text(section.name)
                                    Spacer()
                                }
                                
                                ForEach(section.phrases.sorted{ $0.position < $1.position }) { phrase in
                                    HStack() {
                                        Text("\(viewModel.render(phrase: phrase))").font(.body.monospaced())
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 2)
                                }
                            }
                        }
                        
                    }
                    if (viewModel.inEditMode) {
                        HStack {
                            Button(action: {
                                viewModel.remove(section: section)
                            }) {
                                Image(systemName: "x.square")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)
                            
                            Button(action: {
                                viewModel.moveUp(section: section)
                            }) {
                                Image(systemName: "arrowshape.up")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)
                            
                            Button(action: {
                                viewModel.moveDown(section: section)
                            }) {
                                Image(systemName: "arrowshape.down")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)
                            
                            Button(action: {
                                viewModel.addSection(after: section)
                            }) {
                                Image(systemName: "plus.app")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)

                            NavigationLink(value: DetailDestination.editSection(section: section)) {
                                Image(systemName: "square.and.pencil")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)

                        }
                    }

                }.padding()
            }
            
            if (viewModel.inEditMode) {
                NavigationLink(value: DetailDestination.newSection(song: viewModel.song)) {
                    Text("Add Section")
                }
            }
            
            Button("Edit Song") {
                viewModel.toggleEditMode()
            }
            
        }
    }
}

#Preview {
    var song = Song(id: UUID(), title: "Test Song", sections: [])
    var section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [])
    var section2 = Section(id: UUID(), name: "Verse 2", song: song, phrases: [])

    var aMinor = Chord(id: UUID(), name: "A Minor", shortName: "Am", imagePath: nil)
    var gMajor = Chord(id: UUID(), name: "G Major", shortName: "G", imagePath: nil)
    var dMajor = Chord(id: UUID(), name: "D Major", shortName: "D", imagePath: nil)
    
    var chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    var chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 7)
    var chordSequenceStep3 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 9)
    var chordSequenceStep4 = ChordSequenceStep(id: UUID(), chord: dMajor, step: 16)

    var chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    var chordSequence2 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep3, chordSequenceStep4])

    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: chordSequence1,
                                  chordSequenceRepeatCount: nil))
    
    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: chordSequence2,
                                  chordSequenceRepeatCount: nil))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: chordSequence1,
                                  chordSequenceRepeatCount: nil))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: chordSequence2,
                                  chordSequenceRepeatCount: nil))

    song.sections.append(section)
    song.sections.append(section2)
    song.key = "C Major"
    song.capo = 3
    
    let viewModel = SongViewModel(song: song, modelContext: nil)
    
    return SongView(viewModel: viewModel)
}
