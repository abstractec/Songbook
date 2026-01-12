//
//  EditInstrumentView.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

import SwiftUI

struct EditInstrumentView: View {
    @State var viewModel: EditInstrumentViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            HStack {
                Text("Name").font(.headline).frame(minWidth: 100, alignment: .leading)
                TextField("Enter Instrument Name", text: $viewModel.name)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 0)
            
            HStack {
                Text("Strings").font(.headline)
                Spacer()
            }.padding(.horizontal)
            
            ForEach(viewModel.instrumentStrings()) { string in
                HStack {
                    Text("\(viewModel.position(for: string)): ")
                    Text(viewModel.render(string: string))
                    Spacer()
                    Button {
                        viewModel.moveUp(string: string)
                    } label: {
                        Image(systemName: "arrow.up")
                            .frame(width: 10, height: 10, alignment: .center)
                        
                    }.padding(.trailing, 16)
                    Button {
                        viewModel.moveDown(string: string)
                    } label: {
                        Image(systemName: "arrow.down")
                            .frame(width: 10, height: 10, alignment: .center)
                        
                    }.padding(.trailing, 32)
                    Button {
                        viewModel.delete(string: string)
                    } label: {
                        Image(systemName: "trash")
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundStyle(.red)
                        
                    }.padding(.horizontal, 4)

                }
            }.padding(.horizontal)
            
            HStack {
                Text("Add New String").font(.headline)
                Spacer()
            }.padding()

            HStack {
                Text("Note")
                Picker("Note", selection: $viewModel.newStringNote) {
                    ForEach(Note.allCases) { note in
                        Text(note.rawValue.capitalized)
                            .tag(note) // Important to set the tag to the actual enum case
                    }
                }
                
                Text("Alteration")
                Picker("Alteration", selection: $viewModel.newStringNoteAlteration) {
                    ForEach (Alteration.allCases) { alteration in
                        Text(alteration.rawValue.capitalized)
                            .tag(alteration) // Important to set the tag to the actual enum case
                    }
                }
                
                Spacer()
                Button {
                    viewModel.addString()
                } label: {
                    Text("Add")
                    Image(systemName: "plus")
                        .frame(width: 10, height: 10, alignment: .center)
                    
                }.padding(.trailing, 32)

            }.padding()
            
            HStack {
                Text("Configurations").font(.headline)
                Spacer()
            }.padding()
            
            ForEach(viewModel.configurations.sorted(by: { $0.name < $1.name })) { configuration in
                HStack {
                    Text(configuration.name)
                    Spacer()
                    Button {
                        viewModel.delete(configuration: configuration)
                    } label: {
                        Image(systemName: "trash")
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundStyle(.red)
                        
                    }.padding(.horizontal, 4)
                }
            }.padding(.horizontal)

            Button {
                viewModel.addConfiguration()
            } label: {
                Text("Add Configuration")
                Image(systemName: "add")
                    .frame(width: 10, height: 10, alignment: .center)
                
            }.padding(.horizontal, 4)

        }
        .sheet(isPresented: $viewModel.showNewConfiguration) {
            VStack {
                HStack {
                    Text("Configuration Name")
                    TextField("Configuration Name", text: $viewModel.configurationName)
                }
                HStack {
                    Text("Capo Position")
                    TextField("Capo Position", text: $viewModel.capoPosition)
                        .onChange(of: viewModel.capoPosition) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            //capoPosition
                            
                            viewModel.updateCapo(filtered)
                        }
                }
                
                HStack {
                    Button {
                        viewModel.cancelAddConfiguration()
                    } label: {
                        Text("Cancel")
                        
                    }
                    
                    Button {
                        viewModel.saveConfiguration()
                    } label: {
                        Text("Save")
                        
                    }
                }
            }.padding()
        }

        Button {
            viewModel.save()
            dismiss()
        } label: {
            Text("Save")
            
        }.padding(.trailing, 32)
    }
}

#Preview {
    let instrument = Instrument(name: "Epiphone Les Paul")
    instrument.strings = [
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 0),
        InstrumentString(id: UUID(), note: .A, noteAlteration: .flat, position: 1),
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 2),
        InstrumentString(id: UUID(), note: .G, noteAlteration: .flat, position: 3),
        InstrumentString(id: UUID(), note: .A, noteAlteration: .flat, position: 4),
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 5),
    ]

    instrument.configurations = [
        InstrumentConfiguration(id: UUID(), name: "3rd fret capo", capoPosition: 3),
        InstrumentConfiguration(id: UUID(), name: "7th fret capo", capoPosition: 7),
    ]
    
    let viewModel = EditInstrumentViewModel(instrument: instrument)

    return EditInstrumentView(viewModel: viewModel)
}
