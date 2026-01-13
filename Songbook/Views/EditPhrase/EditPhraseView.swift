//
//  EditPhraseView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI
import SwiftData

struct EditPhraseView: View {
    @Environment(\.dismiss) var dismiss

    @State var viewModel: EditPhraseViewModel
    @State private var showingAddChordSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack {
                    HStack {
                        Text("Phrase").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Phrase Lyric", text: $viewModel.lyric)
                            .onChange(of: viewModel.lyric) { oldValue, newValue in
                                viewModel.updateLyric(newValue)
                            }
                                                
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)

                    HStack {
                        Text("Repeats").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter number of repeats", text: $viewModel.repeats)
                            .onChange(of: viewModel.repeats) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                viewModel.updateRepeats(filtered)
                                
                                viewModel.updateChordSequence()
                            }
        #if os(iOS)
                            .keyboardType(.numberPad)
        #endif

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)

                    if (viewModel.hasLyrics()) {
                        HStack {
                            VStack {
                                Spacer()
//                                Text("Spacing").font(.footnote)
                                
                                VStack {
                                    Button {
                                        viewModel.increasePreLyrics()
                                    } label: {
                                        Image(systemName: "plus.circle")
                                    }.padding(.trailing, 4)
                                        .frame(maxWidth: 40, maxHeight: 40)
                                    
                                    Button {
                                        viewModel.decreasePreLyrics()
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }.padding(.trailing, 4)
                                        .frame(maxWidth: 40, maxHeight: 40)
                                }
                                Spacer()
                            }
                            .padding(.trailing, 16)

                            VStack {
                                ForEach(Array(viewModel.lyrics.enumerated()), id: \.element) { index, lyric in
                                    LyricChordEditor(lyric: lyric, viewModel: viewModel, startStep: viewModel.startStepForIndex(index))
                                }
                            }

                            VStack {
                                Button {
                                    viewModel.increasePostLyrics()
                                } label: {
                                    Image(systemName: "plus.circle")
                                }.padding(.trailing, 4)
                                    .frame(maxWidth: 40, maxHeight: 40)

                                Button {
                                    viewModel.decreasePostLyrics()
                                } label: {
                                    Image(systemName: "minus.circle")
                                }.padding(.trailing, 4)
                                    .frame(maxWidth: 40, maxHeight: 40)
                            }
                            .padding(.leading, 16)

                        }
                    } else {
                        PhraseChordEditor(viewModel: viewModel)
                    }
                    
                    HStack() {
                        Text("Will display as")
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding()
                    
                    HStack() {
                        HStack() {
                            Text("\(viewModel.renderedPhrase)").font(.body.monospaced())
                            Spacer()
                        }
                        .padding()
                        .border(Color.gray, width: 1)
                    }
                    .padding()
                
                    Button("Save Me") {
                        self.viewModel.savePhrase()
                        dismiss()
                    }
                }

            }
        }
        .onAppear() {
            viewModel.updateChordSequence()
        }
    }
    
}
    
struct SelectChordView: View {
    @State var viewModel: EditPhraseViewModel
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Chord.rootRawValue) var chords: [Chord]
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            VStack {
                ScrollView {
                    ForEach(chords) { chord in
                        HStack {
                            Button("\($viewModel.wrappedValue.name(for: chord))") {
                                viewModel.setChord(chord, atPosition: viewModel.selectedSpace ?? 0)
                                dismiss()
                            }
                            Spacer()
                        }.padding(.horizontal)
                    }
                }
                
                Spacer()
                
                NavigationLink(value: EditPhraseDestination.chordBuilder(chord: nil)) {
                    Image(systemName: "music.quarternote.3")
                    Text("Add Chord")
                }
                
                
                Button("Cancel") {
                    dismiss()
                }.padding(.vertical)
            }
            .navigationTitle("Select Chord")
            .navigationDestination(for: EditPhraseDestination.self) { destination in
                switch destination {
                case .chordBuilder(let chord):
                    let viewModel = ChordBuilderViewModel(modelContext: viewModel.modelContext, chord: chord)
                    
                    ChordBuilderView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview("No Lyrics") {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
  
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)
    
    modelContainer.mainContext.insert(aMinor)
    modelContainer.mainContext.insert(cMajor)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

//    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics, and it will wrap")
    let phrase = Phrase(chordSequence: chordSequence1)

    let viewModel = EditPhraseViewModel(section: Section.emptySection, phrase: phrase)

    return EditPhraseView(viewModel: viewModel).modelContainer(modelContainer)
}

#Preview("Two Lines of Lyrics") {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
  
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)
    
    modelContainer.mainContext.insert(aMinor)
    modelContainer.mainContext.insert(cMajor)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics, and it will wrap")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)

    let viewModel = EditPhraseViewModel(section: Section.emptySection, phrase: phrase)

    return EditPhraseView(viewModel: viewModel).modelContainer(modelContainer)
}

#Preview("One Line of Lyrics") {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
  
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)
    
    modelContainer.mainContext.insert(aMinor)
    modelContainer.mainContext.insert(cMajor)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)

    let viewModel = EditPhraseViewModel(section: Section.emptySection, phrase: phrase)

    return EditPhraseView(viewModel: viewModel).modelContainer(modelContainer)
}
