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
                                
                                ForEach(section.phrases) { phrase in
                                    HStack() {
                                        Text("\(viewModel.render(phrase: phrase))").font(.body.monospaced())
                                        Spacer()
                                    }.padding(.horizontal, 8)
                                }
                            }
//                            .containerRelativeFrame(.horizontal, count: 100, span: 20, alignment: .leading)
//                            VStack{
//                                Text("delete")
//                            }
//                            .containerRelativeFrame(.horizontal, count: 100, span: 80, alignment: .trailing)
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

                            Button(action: {
                                viewModel.edit(section: section)
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)

                        }
                    }

                }.padding()
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

    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: ChordSequence(id: UUID(), chords: [aMinor, gMajor], spacing: [0, 7]),
                                  chordSequenceRepeatCount: nil))
    
    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: ChordSequence(id: UUID(), chords: [aMinor, gMajor, dMajor], spacing: [0, 7, 16]),
                                  chordSequenceRepeatCount: nil))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: ChordSequence(id: UUID(), chords: [aMinor, gMajor], spacing: [0, 7]),
                                  chordSequenceRepeatCount: nil))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: ChordSequence(id: UUID(), chords: [aMinor, gMajor, dMajor], spacing: [0, 7, 16]),
                                  chordSequenceRepeatCount: nil))

    song.sections.append(section)
    song.sections.append(section2)
    song.key = "C Major"
    song.capo = 3
    
    let viewModel = SongViewModel(song: song)
    
    return SongView(viewModel: viewModel)
}
