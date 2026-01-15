//
//  SongbookApp.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI
import SwiftData

@main
struct SongbookApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Song.self,
            Chord.self,
            Section.self,
            Phrase.self,
            ChordSequence.self,
            ChordSequenceStep.self,
            Instrument.self,
            InstrumentString.self,
            InstrumentConfiguration.self,
            Playlist.self,
            SongPerformance.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
