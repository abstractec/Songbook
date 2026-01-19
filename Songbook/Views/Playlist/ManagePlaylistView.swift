//
//  ManagePlaylistView.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import SwiftUI
import SwiftData

struct ManagePlaylistView: View {
    @State var viewModel: ManagePlaylistViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingAddSongSheet = false
    @State private var detailPath = NavigationPath()

    @Query(sort: \Song.title) var songs: [Song]
    @Query(sort: \Instrument.name) var instruments: [Instrument]


    var body: some View {
        VStack {
            ScrollView {
                Text(viewModel.title).font(.title)

                ForEach(viewModel.songPerformances) { performance in
                    SongPerformanceRow(songPerformance: performance, viewModel: viewModel.buildSongPerformanceRowViewModel(for: performance))
                }.padding(.horizontal)
            }
            
            // Let's do a sheet?
            Button(action: {
                showingAddSongSheet.toggle()
            }) {
                Text("Add Song to Playlist")
            }
        }
        .sheet(isPresented: $showingAddSongSheet) {
            NavigationStack(path: $detailPath) {
                AddSongToPlaylistView(viewModel: viewModel)
                    .navigationDestination(for: AddSongToPlaylistDestination.self) { destination in
                        switch destination {
                        case .addInstrument(let song, let position):
                            AttachInstrumentToSongView(song: song, position: position, viewModel: viewModel, showingAddSongSheet: $showingAddSongSheet)
                            
                        default:
                            Text("shouldn't be here")
                        }
                    }
            }
            
            Button(action: {
                showingAddSongSheet.toggle()
            }) {
                Text("Cancel")
            }.padding(.vertical)
        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let song = Song(id: UUID(), title: "Song One", sections: [], artist: "Artist One",)
    let performance1 = SongPerformance(id: UUID(), song: song, position: 0)
    
    let playlist = Playlist(id: UUID(), name: "First Playlist", songPerformances: [performance1])
    let viewModel = ManagePlaylistViewModel(playlist: playlist)
    
    modelContainer.mainContext.insert(song)
   
    return ManagePlaylistView(viewModel: viewModel).modelContainer(modelContainer)
}
