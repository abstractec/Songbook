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
        ScrollView {
            Text("Chord Manager").font(.headline)
            
            if (chords.isEmpty) {
                Text("You don't have any chords, why not create one?")
            }
            
            ForEach(chords) { chord in
                HStack {
                    Text("\(viewModel.longName(for: chord))")
                    Spacer()
                    Button(action: {
                        viewModel.delete(chord: chord)
                    }) {
                    
                        Image(systemName: "trash")
                    }
                }
            }.padding(.horizontal)

            NavigationLink(value: DetailDestination.chordBuilder(chord: nil)) {
                Text("Chord Builder")
            }.buttonStyle(PlainButtonStyle())

        }
    }
}

#Preview {
    
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    
    let aMinor = Chord(id: UUID(), root: .A, chordType: .major)
    
    modelContainer.mainContext.insert(aMinor)
    
    
//    ,
//            Chord(id: UUID(), name: "G major", shortName: "G", imagePath: nil),
//            Chord(id: UUID(), name: "D major", shortName: "D", imagePath: nil),
//            Chord(id: UUID(), name: "E 7", shortName: "E7", imagePath: nil),
//        ]
//        )
    let viewModel = ChordManagerViewModel()
    let view = ChordManagerView(viewModel: viewModel).modelContainer(modelContainer)

    return view
}
