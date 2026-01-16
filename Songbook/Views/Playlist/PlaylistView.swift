//
//  SongPerformanceView.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI

struct PlaylistView: View {
    @State var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.title).font(.title)
            ScrollView {
                ForEach(viewModel.songPerformances) { performance in
                    SongPerformanceRow(songPerformance: performance, viewModel: viewModel.buildSongPerformanceRowViewModel(for: performance), canDelete: false)

                }.padding(.horizontal)
                
            }
            
            NavigationLink(value: DetailDestination.performPlaylist(playlist: viewModel.playlist)) {
                Image(systemName: "play")
                Text("Go!")
            }
            
        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    let song = Song(id: UUID(), title: "Song One", sections: [], artist: "Artist One",)
    let performance1 = SongPerformance(id: UUID(), song: song, position: 0)

    let song2 = Song(id: UUID(), title: "Song Two", sections: [], artist: "Blur",)
    let performance2 = SongPerformance(id: UUID(), song: song2, position: 1)

    let playlist = Playlist(id: UUID(), name: "Test", songPerformances: [performance1, performance2])
    let viewModel = PlaylistViewModel(playlist: playlist, modelContext: modelContainer.mainContext)
    PlaylistView(viewModel: viewModel).modelContainer(modelContainer)
}
