//
//  SongPerformanceView.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI

struct SongPerformanceView: View {
    @State var viewModel: SongPerformanceViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let playlist = Playlist(id: UUID(), name: "Test", songPerformances: [])
    let viewModel = SongPerformanceViewModel(playlist: playlist)
    SongPerformanceView(viewModel: viewModel)
}
