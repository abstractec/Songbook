//
//  AddSongToPlaylistView.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import SwiftUI
import SwiftData

struct AddSongToPlaylistView: View {
    @State var viewModel: ManagePlaylistViewModel
    @Query(sort: \Song.title) var songs: [Song]

    var body: some View {
        VStack {
            Text("Select Song").font(.headline)
            ScrollView {
                ForEach(songs) { song in
                    NavigationLink(value: AddSongToPlaylistDestination.addInstrument(song: song)) {
                        HStack {
                            Text(song.title)
                            Spacer()
                        }
                        
                    }
                }
            }
        }.padding()
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
   
    return AddSongToPlaylistView(viewModel: viewModel).modelContainer(modelContainer)

}
