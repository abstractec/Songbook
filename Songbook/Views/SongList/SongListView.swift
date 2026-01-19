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
    @State var viewModel: SongListViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(songs) { song in
                    SongListRow(song: song, viewModel: viewModel)
                }
                .id(songs.count)
            }
            HStack {
                HStack {
                    Button {
                        viewModel.isImporting = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                        Text("Import Song")
                    }.padding(.trailing, 2)
                        .fileImporter(
                            isPresented: $viewModel.isImporting,
                            allowedContentTypes: [.json],
                            allowsMultipleSelection: false
                        ) { result in
                        switch result {
                        case .success(let urls):
                            guard let url = urls.first else { return }
                            viewModel.importSong(from: url)
                        case .failure(let error):
                            print("Import failed: \(error.localizedDescription)")
                        }
                    }
                    
                    NavigationLink(value: DetailDestination.newSong) {
                        Text("Add New Song")
                    }

                }
            }
        }
    }
}

struct SongListRow: View {
    var song: Song
    var viewModel: SongListViewModel
    @State private var showingConfirmation = false

    var body: some View {
        HStack {
            NavigationLink(value: DetailDestination.viewSong(song: song)) {
                Text("\(song.title)")
                Spacer()
                Button(action: {
                    showingConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .frame(width: 10, height: 10, alignment: .center)
                        .foregroundStyle(.red)
                }.confirmationDialog(
                    "Are you sure?",
                    isPresented: $showingConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        viewModel.delete(song: song)
                    }
                } message: {
                    Text("This action cannot be undone.")
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
