//
//  PhraseChordEditor.swift
//  Songbook
//
//  Created by John Haselden on 05/01/2026.
//

import SwiftUI

struct PhraseChordEditor: View {
    var lyric: String = ""
    @State var viewModel: EditPhraseViewModel
    @State private var showingSheet = false
    let chordRenderer = PlainTextChordRenderer()
    @State private var showingConfirmation = false

    var body: some View {
        VStack {
            Text("Chord Picker").font(.headline)
            
            ForEach (viewModel.phrase?.chordSequence.sequence.sorted(by: { $0.step < $1.step }) ?? []) { chordSequenceStep in
                HStack {
                    Text("\(chordSequenceStep.step)")
                    Text("\(chordRenderer.renderShortName(chord: chordSequenceStep.chord))")
                    Spacer()
                    Button {
                        showingConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundStyle(.red)
                    }.confirmationDialog(
                        "Are you sure?",
                        isPresented: $showingConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            viewModel.delete(chordSequenceStep: chordSequenceStep)
                        }
                    } message: {
                        Text("This action cannot be undone.")
                    }

                }.padding(.horizontal)
            }
            
            Button(action: {
                showChordPicker()
            }, label: {
                Text("Add Chord")
            })
            Spacer()
        }
        .sheet(isPresented: $showingSheet) {
            SelectChordView(viewModel: viewModel)
        }
    }
    
    func showChordPicker() {
        showingSheet.toggle()
    }

}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
  
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)
    
    modelContainer.mainContext.insert(aMinor)
    modelContainer.mainContext.insert(cMajor)
    
    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)
    let chordSequence = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    let phrase = Phrase(chordSequence: chordSequence)
    
    let section = Section.emptySection
    section.phrases = [phrase]

    let viewModel = EditPhraseViewModel(section: section, phrase: phrase)

    return PhraseChordEditor(viewModel: viewModel).modelContainer(modelContainer)
}
