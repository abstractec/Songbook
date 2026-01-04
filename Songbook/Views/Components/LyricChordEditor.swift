//
//  LyricChordEditor.swift
//  Songbook
//
//  Created by John Haselden on 14/12/2025.
//

import SwiftUI

struct LyricChordEditor: View {
    var lyric: String = ""
    @State var viewModel: EditPhraseViewModel
    var startStep: Int = 0
    @State private var showingSheet = false

    var body: some View {
        VStack {
            Grid {
                GridRow {
                    ForEach(0..<lyric.count, id: \.self) { number in
                        if let chord = viewModel.chordForPosition(startStep + number) {
                            Button(action: {
                                viewModel.removeChordAt(startStep + number)
                            }) {
                            Text(viewModel.shortName(for: chord))
                                    .rotationEffect(Angle(degrees: 270))
                                    .padding(0)
                                    .frame(width:100, height:0)
                                    .background(Color.blue)
                                    .foregroundColor(.black)
                                    .font(.body.monospaced()) // Apply 90-degree rotation
                            }
                            .frame(width:15, height:150)
                            
                            
                        } else {
                            Button(action: {
                                viewModel.selectedSpace = startStep + number
                                showChordPicker(for: startStep + number)
                            }) {
                                Image(systemName: "plus.circle.fill").frame(width: 10, height: 10, alignment: .center)
                            }
                            .frame(width:15, height:150)
                            
                        }
                    }.padding(0)
                }.onAppear() {
                    viewModel.currentLyricStep = 0
                }
                GridRow {
                    ForEach(0..<lyric.count, id: \.self) { number in
                        if let _ = viewModel.chordForPosition(startStep + number) {
                            Button(action: {
                                viewModel.removeChordAt(startStep + number)
                            }) {
                                Image(systemName: "x.circle.fill")
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundStyle(.red)
                            }
                        } else {
                            Text(" ").font(.body.monospaced()).padding(0)
                        }
                    }
                }.onAppear() {
                    viewModel.currentLyricStep = 0
                }
                GridRow {
                    ForEach(0..<lyric.count, id: \.self) { number in
                        let index = lyric.index(viewModel.lyric.startIndex, offsetBy: number)
                        let char = lyric[index]
                        
                        Text("\(char)").font(.body.monospaced()).padding(0)
                    }.padding(0)
                }.onAppear() {
                    viewModel.currentLyricStep = 0
                }                
                
            }
            .sheet(isPresented: $showingSheet) {
                SelectChordView(viewModel: viewModel)
            }
        }
    }

    func showChordPicker(for space: Int) {
        viewModel.selectedSpace = space
        showingSheet.toggle()
    }
}

#Preview {
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)
    
    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)
    let chordSequence = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    let lyric = Lyric(id: UUID(), text: "This is a line of lyrics and I will wrap")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence)
    
    let section = Section.emptySection
    section.phrases = [phrase]

    let viewModel = EditPhraseViewModel(section: section, phrase: phrase)

    return LyricChordEditor(lyric: viewModel.lyrics[1], viewModel: viewModel, startStep:31)
}
