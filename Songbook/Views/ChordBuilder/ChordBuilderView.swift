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
                Spacer()
                TextField("C", text: $viewModel.root)
                Picker("Flavor", selection: $viewModel.rootAccidental) {
                    ForEach(NoteAccidentalType.allCases) { accidental in
                        Text(accidental.rawValue.capitalized)
                            .tag(accidental) // Important to set the tag to the actual enum case
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
            
            HStack {
                Toggle("Altered Chord?", isOn: $viewModel.altered)
            }
            
            if (viewModel.altered) {
                HStack {
                    Text("Altered by")
                    Spacer()
                    VStack {
                        Slider(
                            value: $viewModel.alteration,
                            in: 2...13,  // Defines the range from 1 to 10
                            step: 1     // Ensures the value moves in whole number increments
                        )
                        .padding(.horizontal)
                        HStack {
                            Text("2")
                            Spacer()
                            Text("13")
                        }
                        .padding(.horizontal)
                    }
                }
                
                HStack {
                    Text("Alteration Type")
                    Spacer()
                    Picker("Flavor", selection: $viewModel.alterationType) {
                        ForEach(AlterationType.allCases) { alterationType in
                            Text(alterationType.rawValue.capitalized)
                                .tag(alterationType) // Important to set the tag to the actual enum case
                        }
                    }
                }

            }
            
            HStack {
                Toggle("Suspended Chord?", isOn: $viewModel.suspended)
            }
            
            if (viewModel.suspended) {
                HStack {
                    Text("Suspend by")
                    Spacer()
                    VStack {
                        Slider(
                            value: $viewModel.suspendedBy,
                            in: 2...13,  // Defines the range from 1 to 10
                            step: 1     // Ensures the value moves in whole number increments
                        )
                        .padding(.horizontal)
                        HStack {
                            Text("2")
                            Spacer()
                            Text("13")
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Text(viewModel.displayChord)
            Text(viewModel.displayShortChord)
            Spacer()

            Button {
                viewModel.save()
                dismiss()
            } label: {
                Text("Save")
            }

        }.padding()
        
    }
}

#Preview {
    let viewModel = ChordBuilderViewModel()
    ChordBuilderView(viewModel: viewModel)
}
