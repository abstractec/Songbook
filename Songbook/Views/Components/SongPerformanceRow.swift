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
                    viewModel.delete(songPerformance, from: viewModel.playlist)
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 10, height: 10, alignment: .center)
                        .foregroundStyle(.red)
                    
                }.padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
//    SongPerformanceRow()
}
