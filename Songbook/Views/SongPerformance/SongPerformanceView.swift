//
//  SongPerformanceView.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI

struct SongPerformanceView: View {
    @State var viewModel: SongPerformanceViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title).font(.title)
            ScrollView {
                ForEach(viewModel.songPerformances) { performance in
                    SongPerformanceRow(songPerformance: performance, viewModel: viewModel.buildSongPerformanceRowViewModel(for: performance), canDelete: false)

                }.padding(.horizontal)
                
            }
            Button {
                
            } label: {
                Image(systemName: "play")
                Text("Go!")
            }
            
        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let playlist = Playlist(id: UUID(), name: "Test", songPerformances: [])
    let viewModel = SongPerformanceViewModel(playlist: playlist, modelContext: modelContainer.mainContext)
    SongPerformanceView(viewModel: viewModel).modelContainer(modelContainer)
}
