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
                            Button(action: {
                                viewModel.delete(chord: chord)
                            }) {
                                
                                Image(systemName: "trash")
                            }
                        }
                    }
                }.padding(.horizontal)
            }
            
            HStack {
                Button {
                    viewModel.importChords()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                    Text("Import Chords")
                }.padding(.trailing, 2)
                
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
