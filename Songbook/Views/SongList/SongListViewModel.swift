//
//  SongListViewModel.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import SwiftData

@Observable
class SongListViewModel {
    private var modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        
        if let modelContext = self.modelContext {
            let dataRepository = DataRepository(modelContext: modelContext)
            let tmpSongs = dataRepository.loadItems(fetchDescriptor: FetchDescriptor<Song>())
            self.songs = tmpSongs.sorted(by: {$0.title < $1.title})
        }
    }
    
    var songs: [Song] = []
    
    var sortOrder: SingListSort = .title {
        didSet {
            do {
                let tmpSongs = try modelContext?.fetch(FetchDescriptor<Song>()) ?? []
                self.songs = tmpSongs.sorted(by: {$0.title < $1.title})
            } catch {
                // something went awry
                print("can't load songs")
            }
        }
    }
    
    func delete(song: Song) {
        modelContext?.delete(song)
    }
}

enum SingListSort: Hashable {
    case title
    case artist
    case album
}

