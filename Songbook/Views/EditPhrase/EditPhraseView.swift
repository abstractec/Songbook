//
//  EditPhraseView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI

struct EditPhraseView: View {
    @State var viewModel: EditPhraseViewModel
    @State private var showingAddChordSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack {
                    HStack {
                        Text("Phrase").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Phrase Lyric", text: $viewModel.lyric)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                
                HStack(alignment: .top) {
                    VStack {
                        Text("Chords").font(.headline).frame(minWidth: 100, alignment: .leading)
                    }
                    Spacer()
                    VStack {
                        ForEach(viewModel.availableChords, id: \.self) { chord in
                            HStack {
                                Text("\(chord.name)")
                                Spacer()
                            }
                        }
                        HStack {
                            Button("Add Chord") {
                                showingAddChordSheet.toggle()
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                
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
            }
        }
        .sheet(isPresented: $showingAddChordSheet) {
            AddChordSheetView(viewModel: viewModel)
        }
    }
    
    func showChordPicker(for space: Int) {
        viewModel.selectedSpace = space
//        showingSheet.toggle()
    }
}
    
struct SelectChordView: View {
    var viewModel: EditPhraseViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Often wrapped in a NavigationView for better presentation
            VStack {
                Text("Select Chord ")
                    .padding()
                
                ForEach(viewModel.availableChords) { chord in
                    Button("\(chord.name)") {
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
    @State var chordName: String = ""
    @State var shortName: String = ""

    var body: some View {
        NavigationView { // Often wrapped in a NavigationView for better presentation
            VStack {
                TextField("Chord Name", text: $chordName)
                TextField("Short Name", text: $shortName)
                
                    
                Button("Add Chord") {
                    viewModel.addChord(name: chordName, shortName: shortName)
                    dismiss()
                }

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
    var aMinor = Chord(id: UUID(), name: "A Minor", shortName: "Am", imagePath: nil)
    var cMajor = Chord(id: UUID(), name: "C Major", shortName: "C", imagePath: nil)
    var chordSequence = ChordSequence(id: UUID(), chords: [aMinor, cMajor], spacing: [0, 17])
    var lyric = Lyric(id: UUID(), text: "This should be a line of lyrics, and it will wrap")
    var phrase = Phrase(lyric: lyric, chordSequence: chordSequence)

    var viewModel = EditPhraseViewModel(phrase: phrase)

    return EditPhraseView(viewModel: viewModel)
}
