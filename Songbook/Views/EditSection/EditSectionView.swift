//
//  EditSectionView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI

struct EditSectionView: View {
    @Environment(\.dismiss) var dismiss

    @State var viewModel: SectionViewModel
    @State private var path = NavigationPath()

    var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        
                        Text("Name").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Section Name", text: $viewModel.name)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                }
                
                ForEach(viewModel.phrases) { phrase in
                    VStack() {
                        HStack() {
                            Text("\(viewModel.render(phrase: phrase))").font(.body.monospaced())
                            Spacer()
                        }
                        HStack() {
                            Spacer()
                            NavigationLink(value: DetailDestination.editPhrase(section: viewModel.section, phrase: phrase)) {
                                Image(systemName: "square.and.pencil")
                                    .frame(width: 10, height: 10, alignment: .center)
                            }.padding(.horizontal)

                            Button {
                                viewModel.moveUp(phrase: phrase)
                            } label: {
                                Image(systemName: "arrowshape.up")
                                    .frame(width: 10, height: 10, alignment: .center)

                            }.padding(.horizontal, 4)
                            Button {
                                viewModel.moveDown(phrase: phrase)
                            } label: {
                                Image(systemName: "arrowshape.down")
                                    .frame(width: 10, height: 10, alignment: .center)

                            }.padding(.horizontal, 4)
                            Button {
                                viewModel.duplicate(phrase: phrase)
                            } label: {
                                Image(systemName: "document.on.document")
                                    .frame(width: 10, height: 10, alignment: .center)

                            }.padding(.horizontal, 4)
                            Button {
                                viewModel.delete(phrase: phrase)
                            } label: {
                                Image(systemName: "trash")
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .foregroundStyle(.red)

                            }.padding(.horizontal, 4)

                            
                            
                        }
                    }
                    .padding()
                    .border(Color.gray, width: 1)

                }.padding()

                HStack {
                    Spacer()
                    NavigationLink(value: DetailDestination.newPhrase(section: viewModel.section)) {
                        Text("Add Phrase")
                    }

                    Spacer()
                }.padding(.top, 16)

                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }

                    Spacer()
                }.padding(.top, 16)
            }
            .navigationTitle("Edit Section")
            .navigationDestination(for: Bool.self) { item in
            }
            .onChange(of: viewModel.section.phrases) {
                viewModel.reload()
            }
        }
    }

#Preview {
    let song = Song.emptySong

    let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [])

    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let gMajor = Chord(id: UUID(), rootNote: .G)
    let dMajor = Chord(id: UUID(), rootNote: .D)
    
    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 7)
    let chordSequenceStep3 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 9)
    let chordSequenceStep4 = ChordSequenceStep(id: UUID(), chord: dMajor, step: 16)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    let chordSequence2 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep3, chordSequenceStep4])

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
    
    let viewModel = SectionViewModel(song: song, section: section)

    return EditSectionView(viewModel: viewModel)
}
