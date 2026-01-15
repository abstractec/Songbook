//
//  PlainTextInstrumentRenderer.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

class PlainTextInstrumentRenderer: InstrumentRenderer {
    func render(instrument: Instrument, andConfiguration configuration: InstrumentConfiguration? = nil) -> String {
        let transposer = BasicTransposer()
        var tuning = ""
        
        if let config = configuration, let capo = config.capoPosition {
            tuning += "Capo: \(capo): "
        }
        
        for string in instrument.strings.sorted(by: { $0.position > $1.position }) {
            if let config = configuration, let capo = config.capoPosition {
                if let transposed = transposer.noteTransposer(string.note, alteration: string.noteAlteration, by: capo) { // it's minus because that's the way guitarists think
                    tuning += "\(transposed.0) "
                }

            } else {
                tuning += "\(string.note.rawValue) "
            }
        }
        
        return "\(instrument.name): \(tuning)"
    }
    
    func renderShortName(instrument: Instrument, andConfiguration configuration: InstrumentConfiguration? = nil) -> String {
        if let config = configuration, let capo = config.capoPosition {
            let tuning = "Capo: \(capo) "
            return "\(instrument.name): \(tuning)"
        }
        
        return "\(instrument.name)"
    }
    
    func render(instrumentString: InstrumentString) -> String {
        var output = "\(instrumentString.note.rawValue)"
        switch instrumentString.noteAlteration {
        case .flat:
            output += "b"
        case .sharp:
            output += "#"
        default:
            break
        }
        
        return output
    }


}
