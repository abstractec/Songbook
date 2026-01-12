//
//  InstrumentsViewModel.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

import Foundation
import SwiftData

@Observable
class InstrumentsViewModel {
    private var modelContext: ModelContext?
    private var instrumentRenderer = PlainTextInstrumentRenderer()
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func render(instrument: Instrument) -> String {
        return self.instrumentRenderer.render(instrument: instrument, andConfiguration: nil)
    }

}
