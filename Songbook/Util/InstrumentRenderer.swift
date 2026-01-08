//
//  InstrumentRenderer.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

protocol InstrumentRenderer {
    func render(instrument: Instrument) -> String
    func renderShortName(instrument: Instrument) -> String

}
