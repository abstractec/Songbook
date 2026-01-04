//
//  SongListView.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import SwiftUI
import SwiftData

struct SongListView: View {
    @Query(sort: \Song.title) private var songs: [Song]
    var viewModel: SongListViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(songs) { song in
                    SongListRow(song: song, viewModel: viewModel)
                }
                .id(songs.count)
            }
            NavigationLink(value: DetailDestination.newSong) {
                Text("Add New Song")
            }
        }
    }
}

struct SongListRow: View {
    var song: Song
    var viewModel: SongListViewModel
    
    var body: some View {
        HStack {
            NavigationLink(value: DetailDestination.viewSong(song: song)) {
                Text("\(song.title)")
                Spacer()
                Button(action: {
                    viewModel.delete(song: song)
                }) {
                    Image(systemName: "x.circle.fill")
                        .frame(width: 10, height: 10, alignment: .center)
                        .foregroundStyle(.red)
                }

            }
        }.padding(.horizontal)
            .padding(.vertical, 4)
    }
}

#Preview {
    let viewModel = SongListViewModel()
    viewModel.songs = [
        Song(id: UUID(), title: "Song 1", sections: []),
        Song(id: UUID(), title: "Song 2", sections: []),
        Song(id: UUID(), title: "Song 3", sections: []),
        Song(id: UUID(), title: "Song 4", sections: []),
    ]
    
    return SongListView(viewModel: viewModel)
}
