//
//  SongPerformanceRow.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI

struct SongPerformanceRow: View {
    var songPerformance: SongPerformance
    var viewModel: SongPerformanceRowViewModel
    var canDelete: Bool? = true
    @State private var showingConfirmation = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(songPerformance.song.title)
                
                HStack {
                    Text(songPerformance.instrument?.name ?? "")
                    Text(songPerformance.instrumentConfiguration?.name ?? "")
                }
                
            }
            Spacer()
            Button {
                viewModel.moveUp(songPerformance, in: viewModel.playlist)
            } label: {
                Image(systemName: "arrow.up")
                    .frame(width: 10, height: 10, alignment: .center)
                
            }.padding(.trailing, 16)
            Button {
                viewModel.moveDown(songPerformance, in: viewModel.playlist)
            } label: {
                Image(systemName: "arrow.down")
                    .frame(width: 10, height: 10, alignment: .center)
                
            }.padding(.trailing, 32)
            
            if (canDelete ?? true) {
                Button {
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
                        viewModel.delete(songPerformance, from: viewModel.playlist)
                    }
                } message: {
                    Text("This action cannot be undone.")
                }.padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    
    let guitar2 = Instrument(id: UUID(), name: "Guitar", strings: [])
    
    let instrumentConfiguration1 = InstrumentConfiguration(id: UUID(), name: "Capo at 3rd Fret", capoPosition: 3)
    let instrumentConfiguration2 = InstrumentConfiguration(id: UUID(), name: "Capo at 7th Fret", capoPosition: 7)
    
    guitar2.configurations = [instrumentConfiguration1, instrumentConfiguration2]

    let song = Song(id: UUID(), title: "Song One", sections: [], artist: "Artist One",)
    let performance1 = SongPerformance(id: UUID(), song: song, instrument: guitar2, instrumentConfiguration: instrumentConfiguration1, position: 0)
    
    let playlist = Playlist(id: UUID(), name: "First Playlist", songPerformances: [performance1])
    let viewModel = SongPerformanceRowViewModel(songPerformance: performance1, playlist: playlist, modelContext: modelContainer.mainContext)
    
    modelContainer.mainContext.insert(song)

    return SongPerformanceRow(songPerformance: performance1, viewModel: viewModel).modelContainer(modelContainer)
}
