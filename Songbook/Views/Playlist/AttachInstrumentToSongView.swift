//
//  AttachInstrumentToSongView.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI
import SwiftData

struct AttachInstrumentToSongView: View {
    var song: Song
    var position: Int?

    @State var viewModel: ManagePlaylistViewModel    
    @Query(sort: \Instrument.name) var instruments: [Instrument]
    
    @Binding var showingAddSongSheet: Bool

    var body: some View {
        VStack {
            Text("Add Instrument")
            ScrollView {
                ForEach(instruments) { instrument in
                    HStack {
                        Button {
                            viewModel.attach(instrument, to: song, at: position)
                            showingAddSongSheet.toggle()
                        } label: {
                            Text(viewModel.render(instrument: instrument))
                        }
                        
                        Spacer()
                    }
                    
                    ForEach(instrument.configurations) { configuration in
                        HStack {
                            Button {
                                viewModel.attach(instrument, with: configuration, to: song, at: position)
                                showingAddSongSheet.toggle()
                            } label: {
                                Text(viewModel.render(instrument: instrument, configuration: configuration))
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            Button {
                viewModel.skipAttachInstrument(for: song)
                showingAddSongSheet.toggle()
            } label: {
                Text("Skip")
            }
            
        }
    }
}

#Preview {
    let instrument = Instrument(name: "Epiphone Les Paul")
    instrument.strings = [
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 0),
        InstrumentString(id: UUID(), note: .A, noteAlteration: .flat, position: 1),
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 2),
        InstrumentString(id: UUID(), note: .G, noteAlteration: .flat, position: 3),
        InstrumentString(id: UUID(), note: .A, noteAlteration: .flat, position: 4),
        InstrumentString(id: UUID(), note: .D, noteAlteration: .flat, position: 5),
    ]

    instrument.configurations = [
        InstrumentConfiguration(id: UUID(), name: "3rd fret capo", capoPosition: 3),
        InstrumentConfiguration(id: UUID(), name: "7th fret capo", capoPosition: 7),
    ]
    
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let song = Song(id: UUID(), title: "Song One", sections: [], artist: "Artist One",)
    let performance1 = SongPerformance(id: UUID(), song: song, position: 0)
    
    let playlist = Playlist(id: UUID(), name: "First Playlist", songPerformances: [performance1])
    let viewModel = ManagePlaylistViewModel(playlist: playlist)
    
    modelContainer.mainContext.insert(song)
    modelContainer.mainContext.insert(instrument)
    
    
    return AttachInstrumentToSongView(song: song, viewModel: viewModel, showingAddSongSheet: .constant(true)).modelContainer(modelContainer)
}
