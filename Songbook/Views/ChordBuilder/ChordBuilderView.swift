//
//  ChordBuilderView.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import SwiftUI

struct ChordBuilderView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: ChordBuilderViewModel
    
    var body: some View {
        VStack {
            Text("Chord Builder").font(.title)
            Spacer()
            HStack {
                Text("Root Note")
                Picker("Note", selection: $viewModel.rootNote) {
                    ForEach(NoteName.allCases) { note in
                        Text(note.rawValue.capitalized)
                            .tag(note) // Important to set the tag to the actual enum case
                    }
                }
                Spacer()

                Picker("Alteration", selection: $viewModel.rootNoteAlteration) {
                    ForEach (Alteration.allCases) { alteration in
                        Text(alteration.rawValue.capitalized)
                            .tag(alteration) // Important to set the tag to the actual enum case
                    }
                }
            }
            
            HStack {
                Text("Chord Type")
                Spacer()
                Picker("Flavor", selection: $viewModel.chordType) {
                    ForEach(ChordType.allCases) { chordType in
                        Text(chordType.rawValue.capitalized)
                            .tag(chordType) // Important to set the tag to the actual enum case
                    }
                }
            }
            
            if (viewModel.chordType == .seventh) {
                HStack {
                    Text("Seventh Type")
                    Spacer()
                    Picker("Type", selection: $viewModel.seventhType) {
                        ForEach(SeventhType.allCases) { seventhType in
                            Text(seventhType.rawValue.capitalized)
                                .tag(seventhType) // Important to set the tag to the actual enum case
                        }
                    }
                }
            }

            // TODO: extended and added ... eek!

            HStack {
                Toggle("Is Suspended?", isOn: $viewModel.isSuspended)
            }

            if (viewModel.isSuspended) {
                HStack {
                    Text("Suspended by")
                    Spacer()
                    Picker("Suspended by", selection: $viewModel.suspendedType) {
                        ForEach (SuspendedType.allCases) { suspension in
                            Text(suspension.rawValue.capitalized)
                                .tag(suspension) // Important to set the tag to the actual enum case
                        }
                    }
                }
            }
            HStack {
                Toggle("Has Bass Note?", isOn: $viewModel.hasBassNote)
            }

            if (viewModel.hasBassNote) {
                HStack {
                    Text("Bass Note")
                    Spacer()
                    Picker("Note", selection: $viewModel.bassNote) {
                        ForEach(NoteName.allCases) { note in
                            Text(note.rawValue.capitalized)
                                .tag(note) // Important to set the tag to the actual enum case
                        }
                    }
                    Picker("Alteration", selection: $viewModel.bassNoteAlteration) {
                        ForEach (Alteration.allCases) { alteration in
                            Text(alteration.rawValue.capitalized)
                                .tag(alteration) // Important to set the tag to the actual enum case
                        }
                    }
                }
            }
            
            Text(viewModel.displayChord)
            Text(viewModel.displayShortChord)

            Button {
                viewModel.save()
                dismiss()
            } label: {
                Text("Save")
            }
            Spacer()

        }.padding()
        
    }
}

#Preview {
    let viewModel = ChordBuilderViewModel()
    ChordBuilderView(viewModel: viewModel)
}
