//
//  DataHelper.swift
//  Songbook
//
//  Created by John Haselden on 03/01/2026.
//

import Foundation
import SwiftData

class DataHelper {
    @MainActor func mockModelContainer() -> ModelContainer {
        let schema = Schema([
            Song.self,
            Chord.self,
            Section.self,
            Phrase.self,
            ChordSequence.self,
            ChordSequenceStep.self,
            Instrument.self,
            InstrumentString.self,
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
                
        return container
    }
}
