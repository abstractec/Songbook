//
//  SongListView.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import SwiftUI

struct SongListView: View {
    var viewModel: SongListViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.songs) { song in
                    SongListRow(song: song)
                }
            }
            NavigationLink(value: DetailDestination.newSong) {
                Text("Add New Song")
            }
        }
    }
}

struct SongListRow: View {
    var song: Song
    
    var body: some View {
        HStack {
            NavigationLink(value: DetailDestination.viewSong(song: song)) {
                Text("\(song.title)")
                Spacer()
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
