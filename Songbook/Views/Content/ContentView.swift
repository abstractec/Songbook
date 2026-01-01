//
//  ContentView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Song]

    @State private var sortOrder = SortDescriptor(\Playlist.name)
    @State private var searchText = ""
    @State private var detailPath = NavigationPath()
    @State private var viewModel = ContentViewModel()
    
    @State private var navigateToAddSong = false

    var body: some View {
        NavigationSplitView {
            PlaylistsView(sort: sortOrder, searchString: searchText)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            ForEach(songs) { song in
                NavigationLink(value: DetailDestination.viewSong(song: song)) {
                    Text("Song: \(song.title)")
                }
            }.padding(.bottom, 16)

            NavigationLink(value: DetailDestination.newSong) {
                Text("Add New Song")
            }
            
            NavigationLink(value: DetailDestination.chordManager) {
                Text("Chord Manager")
            }
            
            NavigationStack(path: $detailPath) {
                Text("")
                    .navigationDestination(for: DetailDestination.self) { destination in
                        switch destination {
                        case .newSong:
                            let song = Song(id: UUID(), title: "", sections: [])
                            let viewModel = EditSongViewModel(song: song, modelContext: modelContext)
                            EditSongView(viewModel: viewModel)
                        case .newSection(let song):
                            let section = Section(id: UUID(), name: "", song: song, phrases: [])
                            let viewModel = SectionViewModel(song: song, section: section)
                            EditSectionView(viewModel: viewModel)
                        case .newPhrase(let section):
                            let viewModel = EditPhraseViewModel(section: section, phrase: Phrase.emptyPhrase, modelContext: modelContext)
                            EditPhraseView(viewModel: viewModel)
                        case .editPhrase(let section, let phrase):
                            let viewModel = EditPhraseViewModel(section: section, phrase: phrase, modelContext: modelContext)
                            EditPhraseView(viewModel: viewModel)
                        case .viewSong(let song):
                            let viewModel = SongViewModel(song: song, modelContext: modelContext)
                            SongView(viewModel: viewModel)
                        case .editSection(let section):
                            let viewModel = SectionViewModel(song: section.song, section: section)
                            EditSectionView(viewModel: viewModel)
                        case .chordManager:
                            let viewModel = ChordManagerViewModel(modelContext: modelContext)
                            ChordManagerView(viewModel: viewModel)

                        }
                    }
            }
        }
    }
    
    private func debug(_ string: String) {
        print(string)
    }

}

#Preview {
    ContentView()
        .modelContainer(for: [Song.self, Section.self, Phrase.self, Chord.self], inMemory: true)
}
