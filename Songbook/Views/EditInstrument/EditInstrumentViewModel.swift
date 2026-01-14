//
//  EditInstrumentViewModel.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

import Foundation
import SwiftData

@Observable
class EditInstrumentViewModel {
    private var modelContext: ModelContext?
    
    var instrument: Instrument?
    var name: String = ""
    var strings: [InstrumentString] = []
    
    var newStringNote: Note?
    var newStringNoteAlteration: Alteration?
    var configurations: [InstrumentConfiguration] = []
    
    var showNewConfiguration: Bool = false
    var configurationName: String = ""
    var capoPosition: String = ""
    var capo: Int? = nil
    
    init(modelContext: ModelContext? = nil, instrument: Instrument?, strings: [InstrumentString] = [], newStringNote: Note? = nil, newStringNoteAlteration: Alteration? = nil) {
        self.modelContext = modelContext
        
        if let instrument = instrument {
            self.instrument = instrument
            self.name = instrument.name
            self.strings = instrument.strings
            self.configurations = instrument.configurations
        } else {
            self.strings = strings
        }
        
        self.newStringNote = newStringNote
        self.newStringNoteAlteration = newStringNoteAlteration
    }
    
    func render(string: InstrumentString) -> String {
        let renderer = PlainTextInstrumentRenderer()
        
        return renderer.render(instrumentString: string)
        
    }
    
    func instrumentStrings() -> [InstrumentString] {
        return strings.sorted(by: { $0.position < $1.position })
    }
    
    func position(for string: InstrumentString) -> Int {
        return strings.count - string.position
    }
    
    func delete(string: InstrumentString) {
        if let idx = strings.firstIndex(of: string) {
            strings.remove(at: idx)
            
        }
        
        modelContext?.delete(string)
    }
    
    func delete(configuration: InstrumentConfiguration) {
        if let idx = configurations.firstIndex(of: configuration) {
            configurations.remove(at: idx)
            
        }
        
        modelContext?.delete(configuration)
    }
    
    func moveUp(string: InstrumentString) {
        if string.position == 0 { return }
        
        let targetPosition = string.position - 1
        
        if let swap = strings.first(where: { $0.position == targetPosition }) {
            swap.position = string.position
            string.position = targetPosition
        }
    }
    
    func moveDown(string: InstrumentString) {
        if string.position == strings.count - 1 { return }
        
        let targetPosition = string.position + 1
        
        if let swap = strings.first(where: { $0.position == targetPosition }) {
            swap.position = string.position
            string.position = targetPosition
        }
    }
    
    func addString() {
        if let note = self.newStringNote, let alteration = self.newStringNoteAlteration {
            let string = InstrumentString(id: UUID(), note: note, noteAlteration: alteration, position: strings.count)
            strings.append(string)
            instrument?.strings.append(string)
        } else if let note = self.newStringNote {
            strings.append(InstrumentString(id: UUID(), note: note, position: strings.count))
        } // else do nothing
        
    }
    
    func save() {
        if let instrument = self.instrument {
            instrument.name = self.name
            instrument.strings = self.strings
            
        } else {
            let instrument = Instrument(id: UUID(), name: self.name, strings: self.strings)
            modelContext?.insert(instrument)
            do {
                try modelContext?.save()
            } catch {
                // TODO: error message me
            }
        }
    }
    
    
    func updateCapo(_ capoString: String) {
        if let capo = Int(capoString) {
            self.capo = capo
            self.capoPosition = capoString
        } else {
            print("repeat doesn't seem to be an integer")
        }
    }
    
    func addConfiguration() {
        showNewConfiguration.toggle()
    }
    
    func cancelAddConfiguration() {
        showNewConfiguration.toggle()
    }
    
    func saveConfiguration() {
        let configuration = InstrumentConfiguration(id: UUID(), name: configurationName, capoPosition: capo)
        self.instrument?.configurations.append(configuration)
        
        modelContext?.insert(configuration)
        do {
            try modelContext?.save()
        } catch {
            // TODO: error me
        }
        self.configurations.append(configuration)
        showNewConfiguration.toggle()
    }

}

