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
    @Query(sort: \Song.title) private var songs: [Song]
    @Query(sort: \Playlist.name) private var playlists: [Playlist]
    @Query(sort: \Chord.rootRawValue) private var chords: [Chord]
    @Query(sort: \Instrument.name) private var instruments: [Instrument]

    private var songCount: Int {
        songs.count
    }
    
    private var playlistCount: Int {
        playlists.count
    }

    private var chordCount: Int {
        chords.count
    }

    private var instrumentCount: Int {
        instruments.count
    }

    @State private var sortOrder = SortDescriptor(\Playlist.name)
    @State private var searchText = ""
    @State private var detailPath = NavigationPath()
    @State private var viewModel = ContentViewModel()
    
    @State private var navigateToAddSong = false

    var body: some View {
        NavigationSplitView {
            Text("TBC")
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Text("Welcome to Songbook!")
                            .font(.title)
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding(.horizontal)
                        .padding(.vertical, 4)
                    
                    
                }
                .background(Color.gray)
                .border(Color.gray, width: 4)
                .cornerRadius(8)
                .padding(.horizontal)
                
                Spacer()

                VStack {
                    
                    HStack {
                        NavigationLink(value: DetailDestination.songList) {
                            ContentCountView(iconName: "music.microphone", countName: "Songs", count: songCount, color: .green)
                        }.buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(value: DetailDestination.playlistList) {
                            ContentCountView(iconName: "list.clipboard", countName: "Playlists", count: playlistCount, color: .yellow)
                        }.buttonStyle(PlainButtonStyle())
                        
                    }.padding(.horizontal)
                    
                    NavigationLink(value: DetailDestination.chordManager) {
                        ContentCountView(iconName: "music.quarternote.3", countName: "Chords", count: chordCount, color: .cyan)
                    }.buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    NavigationLink(value: DetailDestination.instrumentsList) {
                        ContentCountView(iconName: "guitars", countName: "Instruments", count: instrumentCount, color: .indigo.opacity(0.7))
                    }.buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                }.padding(.horizontal)

                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        Text("Fully Open Source: visit https://github.com/abstractec/Songbook")
                        Spacer()
                    }.padding(.horizontal)
                        .padding(.vertical, 4)
                    
                    
                }
                .padding(.horizontal)
                            
                NavigationStack(path: $detailPath) {
                    Text("")
                        .navigationDestination(for: DetailDestination.self) { destination in
                        switch destination {
                        case .newSong:
                            let song = Song(id: UUID(), title: "", sections: [])
                            let viewModel = EditSongViewModel(song: song, modelContext: modelContext)
                            EditSongView(viewModel: viewModel)
                        case .newSection(let song):
                            let section = Section(id: UUID(), name: "", song: song, phrases: [], position: song.sections.count)
                            let viewModel = SectionViewModel(song: song, section: section)
                            EditSectionView(viewModel: viewModel)
                        case .newPhrase(let section):
                            let phrase = Phrase.emptyPhrase
                            let viewModel = EditPhraseViewModel(section: section, phrase: phrase, modelContext: modelContext)
                            EditPhraseView(viewModel: viewModel)
                        case .editPhrase(let section, let phrase):
                            let viewModel = EditPhraseViewModel(section: section, phrase: phrase, modelContext: modelContext)
                            EditPhraseView(viewModel: viewModel)
                        case .viewSong(let song):
                            let viewModel = SongViewModel(song: song, modelContext: modelContext)
                            SongView(viewModel: viewModel)
                        case .editSection(let section):
                            
                            if let song = section.song {
                                let viewModel = SectionViewModel(song: song, section: section, modelContext: modelContext)
                                EditSectionView(viewModel: viewModel)

                            }
                        case .chordManager:
                            let viewModel = ChordManagerViewModel(modelContext: modelContext)
                            ChordManagerView(viewModel: viewModel)
                        case .songList:
                            let viewModel = SongListViewModel(modelContext: modelContext)
                            SongListView(viewModel: viewModel)
                        case .chordBuilder(let chord):
                            let viewModel = ChordBuilderViewModel(modelContext: modelContext, chord: chord)
                            
                            ChordBuilderView(viewModel: viewModel)
                        case .instrumentsList:
                            let viewModel = InstrumentsViewModel(modelContext: modelContext)
                            InstrumentsView(viewModel: viewModel)
                        case .editInstrument(let instrument):
                            let viewModel = EditInstrumentViewModel(modelContext: modelContext, instrument: instrument)

                            EditInstrumentView(viewModel: viewModel)
                        case .newInstrument:
                            let viewModel = EditInstrumentViewModel(modelContext: modelContext, instrument: nil)
                            EditInstrumentView(viewModel: viewModel)
                        case .playlistList:
                            let viewModel = PlaylistsViewModel(modelContext: modelContext)
                            PlaylistsView(viewModel: viewModel)
                        case .viewPlaylist(let playlist):
                            let viewModel = PlaylistViewModel(playlist: playlist, modelContext: modelContext)
                            PlaylistView(viewModel: viewModel)
                        case .editPlaylist(let playlist):
                            let viewModel = ManagePlaylistViewModel(playlist: playlist, modelContext: modelContext)
                            ManagePlaylistView(viewModel: viewModel)
                        case .newPlaylist:
                            Text("New playlist please")

                        case .performPlaylist(let playlist):
                            let viewModel = SongPerformanceViewModel(playlist: playlist, modelContext: modelContext)
                            SongPerformanceView(viewModel: viewModel)
                        }
                    }
                }
            }
        }.task {
            viewModel = ContentViewModel(modelContext: self.modelContext)
        }
    }
    
    private func debug(_ string: String) {
        print(string)
    }

}

struct ContentCountView: View {
    var iconName: String
    var countName: String
    var count: Int
    var color: Color
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: self.iconName).font(.title2)
                Text(self.countName).font(.title2)
                Spacer()
            }.padding(.horizontal)
                .padding(.top, 0)
            HStack {
                Text("\(self.count)").font(.largeTitle)
            }
        }
        .frame(minHeight: 150)
        .background(self.color)
        .border(self.color, width: 4)
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Song.self, Section.self, Phrase.self, Chord.self], inMemory: true)
}
