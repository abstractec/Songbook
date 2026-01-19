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
            Text(songPerformance.song.title)
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
//    SongPerformanceRow()
}
