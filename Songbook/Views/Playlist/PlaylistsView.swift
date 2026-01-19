//
//  PlaylistsView.swift
//  Songbook
//
//  Created by John Haselden on 14/01/2026.
//

import SwiftUI
import SwiftData

struct PlaylistsView: View {
    @Query(sort: \Playlist.name) var playlists: [Playlist]
    @State private var showingConfirmation = false

    @State var viewModel: PlaylistsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingAddPlaylist = false

    var body: some View {
        VStack {
            ScrollView {
                Text("Playlists").font(.title)
                
                ForEach(playlists) { playlist in
                    HStack {
                        NavigationLink(value: DetailDestination.viewPlaylist(playlist: playlist)) {
                            VStack {
                                HStack {
                                    Text(playlist.name).font(.headline)
                                    Spacer()
                                }
                                HStack {
                                    if (playlist.songPerformances.count == 1) {
                                        Text("1 Song").font(.subheadline)
                                    } else {
                                        Text("\(playlist.songPerformances.count) Songs").font(.subheadline)
                                    }
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        NavigationLink(value: DetailDestination.editPlaylist(playlist: playlist)) {
                            Image(systemName: "square.and.pencil")
                        }.padding(.horizontal)
                        
                        Button(role: .destructive) {
                            showingConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .frame(width: 10, height: 10, alignment: .center)
                                .foregroundStyle(.red)
                        }.confirmationDialog(
                            "Are you sure?",
                            isPresented: $showingConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                viewModel.delete(playlist)
                            }
                        } message: {
                            Text("This action cannot be undone.")
                        }

                    }
                }
                .padding(.horizontal)
                    
            }
            
            if showingAddPlaylist {
                VStack {
                    HStack {
                        TextField("Enter Playlist Name", text: $viewModel.playlistName)
                        Spacer()
                        Button {
                            viewModel.addPlaylist(with: viewModel.playlistName)
                        } label: {
                            Text("Add")
                        }
                    }
                    .padding()
                    .cornerRadius(8)
                }.transition(.slide)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)

                
            }
            
            Button {
                withAnimation(.easeInOut) {
                    showingAddPlaylist.toggle()
                }
            } label: {
                if !showingAddPlaylist {
                    Text("Add Playlist")
                } else {
                    Text("Cancel")
                }
            }

        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    
    let song = Song(id: UUID(), title: "Song One", sections: [], artist: "Artist One",)
    let performance1 = SongPerformance(id: UUID(), song: song, position: 0)
    
    let playlist = Playlist(id: UUID(), name: "First Playlist", songPerformances: [performance1])
    let playlist2 = Playlist(id: UUID(), name: "Second Playlist", songPerformances: [])

    modelContainer.mainContext.insert(playlist)
    modelContainer.mainContext.insert(playlist2)

    let viewModel = PlaylistsViewModel()
    
    return PlaylistsView(viewModel: viewModel).modelContainer(modelContainer)
}
