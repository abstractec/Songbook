//
//  ChordManagerView.swift
//  Songbook
//
//  Created by John Haselden on 01/01/2026.
//

import SwiftUI
import SwiftData

struct ChordManagerView: View {
    @Query(sort: \Chord.rootRawValue) var chords: [Chord]
    @State private var showingDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet?
    @State private var showingConfirmation = false
    
    @State var viewModel: ChordManagerViewModel
    var body: some View {
        VStack {
            ScrollView {
                Text("Chord Manager").font(.headline)
                
                if (chords.isEmpty) {
                    Text("You don't have any chords, why not create one?")
                }
                
                
                ForEach(chords) { chord in
                    NavigationLink(value: DetailDestination.chordBuilder(chord: chord)) {
                        
                        HStack {
                            Text("\(viewModel.longName(for: chord))")
                            Spacer()
                            Button(role: .destructive, action: {
                                showingConfirmation = true
                            }) {
                                Image(systemName: "trash")
                            }.confirmationDialog(
                                "Are you sure?",
                                isPresented: $showingConfirmation,
                                titleVisibility: .visible
                            ) {
                                Button("Delete", role: .destructive) {
                                    viewModel.delete(chord: chord)
                                }
                            } message: {
                                Text("This action cannot be undone.")
                            }
                        }
                    }
                }.padding(.horizontal)
            }
            
            HStack {
                Button {
                    viewModel.isImporting = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                    Text("Import Chords")
                }.padding(.trailing, 2)
                    .fileImporter(
                        isPresented: $viewModel.isImporting,
                        allowedContentTypes: [.json],
                        allowsMultipleSelection: false
                    ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        viewModel.importChords(from: url)
                    case .failure(let error):
                        print("Import failed: \(error.localizedDescription)")
                    }
                }
                
                Button {
                    viewModel.exportChords(self.chords)
                } label: {
                    Image(systemName: "square.and.arrow.down")
                    Text("Export Chords")
                }.padding(.leading, 2)
                    .fileExporter(
                        isPresented: $viewModel.isExporting,
                        document: viewModel.document,
                        contentType: .json,
                        defaultFilename: "exported_chords.json"
                    ) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to: \(url)")
                        case .failure(let error):
                            print("Export failed: \(error.localizedDescription)")
                        }
                    }
            }
        }
        NavigationLink(value: DetailDestination.chordBuilder(chord: nil)) {
            Image(systemName: "music.quarternote.3")
            Text("Chord Builder")
        }

    }
    
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    
    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .major)
    let gMajor = Chord(id: UUID(), rootNote: .G)
    let dMajor = Chord(id: UUID(), rootNote: .D)
    let a7Sus2 = Chord(id: UUID(), rootNote: .A, chordType: .seventh, seventhType: .dominant, suspendedType: .second)

    modelContainer.mainContext.insert(aMinor)
    modelContainer.mainContext.insert(gMajor)
    modelContainer.mainContext.insert(dMajor)
    modelContainer.mainContext.insert(a7Sus2)
    
    let viewModel = ChordManagerViewModel()
    let view = ChordManagerView(viewModel: viewModel).modelContainer(modelContainer)

    return view
}
