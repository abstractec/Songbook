//
//  PlainTextInstrumentRenderer.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

class PlainTextInstrumentRenderer: InstrumentRenderer {
    func render(instrument: Instrument) -> String {
        let transposer = BasicTransposer()
        var tuning = ""

        if let capo = instrument.capo {
            tuning += "Capo: \(capo) "
        }
        
        for string in instrument.strings.sorted(by: { $0.position > $1.position }) {
            if let capo = instrument.capo {
                if let transposed = transposer.noteTransposer(string.note, alteration: string.noteAlteration, by: capo) { // it's minus because that's the way guitarists think
                    tuning += "\(transposed.0) "
                }

            } else {
                tuning += "\(string.note.rawValue) "
            }
        }
        
        return "\(instrument.name): \(tuning)"
    }
    
    func renderShortName(instrument: Instrument) -> String {
        let transposer = BasicTransposer()
        var tuning = ""

        if let capo = instrument.capo {
            tuning += "Capo: \(capo) "
        }
        
        return "\(instrument.name): \(tuning)"
    }

}
