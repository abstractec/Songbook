//
//  ChordManagerView.swift
//  Songbook
//
//  Created by John Haselden on 01/01/2026.
//

import SwiftUI

struct ChordManagerView: View {
    @State var viewModel: ChordManagerViewModel
    var body: some View {
        ScrollView {
            Text("Chord Manager").font(.headline)
            
            ForEach(viewModel.chords) { chord in
                HStack {
                    Text("\(chord.name)")
                    Spacer()
                    Button(action: {
                        viewModel.delete(chord: chord)
                    }) {
                    
                        Image(systemName: "trash")
                    }
                }
            }.padding(.horizontal)

        }
    }
}

#Preview {
    let viewModel = ChordManagerViewModel()
    viewModel.chords = [
        Chord(id: UUID(), name: "A minor", shortName: "Am", imagePath: nil),
        Chord(id: UUID(), name: "G major", shortName: "G", imagePath: nil),
        Chord(id: UUID(), name: "D major", shortName: "D", imagePath: nil),
        Chord(id: UUID(), name: "E 7", shortName: "E7", imagePath: nil),
    ]
    return ChordManagerView(viewModel: viewModel)
}
