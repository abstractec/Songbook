//
//  AddSongToPlaylistView.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import SwiftUI
import SwiftData

struct AddSongToPlaylistView: View {
    @State var viewModel: PlaylistViewModel
    @Query(sort: \Song.title) var songs: [Song]

    var body: some View {
        VStack {
            Text("Select Song").font(.headline)
            ScrollView {
                ForEach(songs) { song in
                    HStack {
                        Text(song.title)
                        Spacer()
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
    let performance1 = SongPerformance(id: UUID(), name: "Performance One", song: song)
    
    let playlist = Playlist(id: UUID(), name: "First Playlist", songPerformances: [performance1])
    let viewModel = PlaylistViewModel(playlist: playlist)
    
    modelContainer.mainContext.insert(song)
   
    return AddSongToPlaylistView(viewModel: viewModel).modelContainer(modelContainer)

}
