//
//  PlaylistView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI
import SwiftData

struct PlaylistsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: [SortDescriptor(\Playlist.name, order: .forward), SortDescriptor(\Playlist.name)]) var playlists: [Playlist]
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(playlists) { playlist in
                    HStack {
                        Text(playlist.name)
                        Spacer()
                    }.padding(.vertical, 2)
                }
                .padding(.horizontal)
                    
            }
        }.frame(minWidth: 250)
    }
    
    init(sort: SortDescriptor<Playlist>, searchString: String) {
        _playlists = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            } else {
                return $0.name.localizedStandardContains(searchString)
            }
        }, sort: [sort])
    }
}

#Preview {
    PlaylistsView(sort: SortDescriptor(\Playlist.name), searchString: "")
}
