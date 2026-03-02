//
//  SongViewModel.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class SongViewModel {
    let song: Song
    let showKey: Bool
    let key: String
    var instrument: Instrument? = nil
    var instrumentAndConfig: InstrumentAndConfig? = nil
    var isExporting = false

    // leave these two here for when we pass an instrument in for this view model
    let showCapo: Bool = false
    let capo: String = ""
        
    var inEditMode: Bool = false
    var modelContext: ModelContext?
    
    var transposedBy: Int = 0

    var document: JSONDocument?

    init(song: Song, modelContext: ModelContext?, instrument: Instrument? = nil) {
        self.song = song
        
        if let key = self.song.key {
            self.showKey = true
            self.key = key
        } else {
            self.showKey = false
            self.key = ""
        }
        
        self.modelContext = modelContext
        self.instrument = instrument
    }
    
    var exportFilename: String {
        let name = "\(song.title) \(song.artist ?? "")"
        
        return name.snakeCased() ?? name
    }

    
    func render(phrase: Phrase) -> String {
        let songRenderer = PlainTextSongRenderer()
        
        return songRenderer.render(phrase: phrase, transposedBy: self.transposedBy)
    }
    
    func toggleEditMode() {
        inEditMode.toggle()
    }
    
    func moveUp(section: Section) {
        if (section.position >= 0) {
            if let replacement = song.sections.filter({ $0.position == section.position - 1 }).first {
                let originalPosition = section.position
                section.position = originalPosition - 1
                replacement.position = originalPosition
            }
        }
        
        // re-index our items
        reIndexSections()

    }

    func moveDown(section: Section) {
        if (section.position < song.sections.count - 1) {
            if let replacement = song.sections.filter({ $0.position == section.position + 1 }).first {
                let originalPosition = section.position
                section.position = originalPosition + 1
                replacement.position = originalPosition
            }
        }

        // re-index our items
        reIndexSections()
    }

    func duplicate(section: Section) {
        let newSection = section.copy()

        newSection.position = song.sections.count

        modelContext?.insert(newSection)
        
        for phrase in newSection.phrases {
            phrase.section = newSection
            modelContext?.insert(phrase)
        }
        
        do {
            try modelContext?.save()
            song.sections.append(newSection)

            // re-index our items
            reIndexSections()
        } catch {
            // TODO: error me
        }
    }
    
    func delete(section: Section) {
        modelContext?.delete(section)
        
        // re-index our items
        reIndexSections()
    }
    
    func addSection(after section: Section) {
        let position = section.position
        
        let newSection = Section.emptySection
        newSection.name = "New Section"
        
        newSection.position = position + 1
        song.sections.insert(newSection, at: song.sections.firstIndex(of: section)! + 1)
        
        reIndexSections()
    }
    
    func increaseTransposition() {
        transposedBy += 1
    }
    
    func decreaseTransposition() {
        transposedBy -= 1
    }
        
    private func reIndexSections() {
        var lastIdx = 0;
        for section in song.sections.sorted(by: { $0.position < $1.position }) {
            if section.position != lastIdx {
                section.position = lastIdx
            }
            lastIdx += 1
        }
    }
    
    func transpose(for instrumentConfiguration: InstrumentConfiguration) {
        self.transposedBy = -(instrumentConfiguration.capoPosition ?? 0)
    }

    func transpose(instrumentConfiguration: InstrumentAndConfig) {
        self.transposedBy = -(instrumentConfiguration.config.capoPosition ?? 0)
    }
    

    func name(for instrument: Instrument, with configuration: InstrumentConfiguration? = nil) -> String {
        let instrumentRederer = PlainTextInstrumentRenderer()
        return instrumentRederer.renderShortName(instrument: instrument, andConfiguration: configuration)
    }
    
    func instrumentAndConfigurationList(for instruments: [Instrument]) -> [InstrumentAndConfig] {
        var returnMap: [InstrumentAndConfig] = []
        
        for instrument in instruments {
            returnMap.append(InstrumentAndConfig(id: instrument.id, instrument: instrument, config: instrument.defaultConfig))
            
            for config in instrument.configurations {
                returnMap.append(InstrumentAndConfig(id: config.id, instrument: instrument, config: config))
            }
        }
       
        return returnMap
    }
    
    func exportSong() {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        if let encodedData = try? encoder.encode(song) {
            self.document = JSONDocument(data: encodedData)
            self.isExporting = true
        }

    }
    
    @MainActor
    func exportPDF() -> URL {
        
        if let url = self.exportA4MultiPagePDF(view: SongPDFView(song: self.song), filename: "\(song.title).pdf") {
            return url
        } else {
            return URL(string: "")!
        }
    }

    @MainActor
    func exportA4MultiPagePDF(view: some View, filename: String) -> URL? {
        let a4Width: CGFloat = 595.2
        let a4Height: CGFloat = 841.8
        var pageRect = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)
        
        // 1. Get the actual total height of your view first
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: a4Width, height: nil)
        guard let totalSize = renderer.uiImage?.size else { return nil }
        
        let url = URL.documentsDirectory.appending(path: filename)
        guard let context = CGContext(url as CFURL, mediaBox: &pageRect, nil) else { return nil }
        
        let numberOfPages = Int(ceil(totalSize.height / a4Height))
        
        for i in 0..<numberOfPages {
            context.beginPDFPage(nil)
            
            // 2. Calculate the 'Top' of the content for this specific page
            // We need to move the origin so the top of the view's current "slice"
            // aligns with the top of the PDF page (a4Height).
            let currentSliceTop = totalSize.height - (CGFloat(i) * a4Height)
            
            renderer.render { size, renderContext in
                context.saveGState()
                
                // 3. Move the drawing origin
                // We translate the context so the view's Y-coordinate matches
                // the PDF's top-down expectation.
                context.translateBy(x: 0, y: a4Height - currentSliceTop)
                
                renderContext(context)
                context.restoreGState()
            }
            
            context.endPDFPage()
        }
        
        context.closePDF()
        return url
    }


}

struct InstrumentAndConfig: Identifiable, Equatable, Hashable {
    static func == (lhs: InstrumentAndConfig, rhs: InstrumentAndConfig) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var id: UUID
    public var instrument: Instrument
    public var config: InstrumentConfiguration
    
    init(id: UUID, instrument: Instrument, config: InstrumentConfiguration) {
        self.id = id
        self.instrument = instrument
        self.config = config
    }
}
