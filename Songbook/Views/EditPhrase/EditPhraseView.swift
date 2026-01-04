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
                }
                
                ForEach(Array(viewModel.lyrics.enumerated()), id: \.element) { index, lyric in
                    LyricChordEditor(lyric: lyric, viewModel: viewModel, startStep: viewModel.startStepForIndex(index))
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
        .onAppear() {
            viewModel.updateChordSequence()
        }
    }
    
}
    
struct SelectChordView: View {
    @State var viewModel: EditPhraseViewModel
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Chord.rootRawValue) var chords: [Chord]

    var body: some View {
        NavigationView { // Often wrapped in a NavigationView for better presentation
            VStack {
                Text("Select Chord ")
                    .padding()
                                
                ForEach(chords) { chord in
                    Button("\($viewModel.wrappedValue.name(for: chord))") {
                        viewModel.setChord(chord, atPosition: viewModel.selectedSpace ?? 0)
                        dismiss()
                    }
                }

                Button("Press to dismiss") {
                    dismiss()
                }
            }
            .navigationTitle("Modal View")
        }
    }
}

struct AddChordSheetView: View {
    var viewModel: EditPhraseViewModel
    
    @Environment(\.dismiss) var dismiss
    @State var chord: Chord?

    var body: some View {
        NavigationView { // Often wrapped in a NavigationView for better presentation
            VStack {
                TextField("Chord Name", text: viewModel.name(for: $chord))
                TextField("Short Name", text: viewModel.shortName(for: $chord))
                
                    
//                Button("Add Chord") {
//                    viewModel.addChord(chord: $chord.wrappedValue)
//                    dismiss()
//                }

                Button("Cancel") {
                    // 5. Call dismiss() to close the modal
                    dismiss()
                }

            }
            .navigationTitle("Modal View")
            .padding()
        }
    }
}

#Preview {
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics, and it will wrap")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1)

    let viewModel = EditPhraseViewModel(section: Section.emptySection, phrase: phrase)

//    return EditPhraseView(viewModel: viewModel)
//    return EditPhraseView()
}
