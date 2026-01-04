//
//  ChordsDocument.swift
//  Songbook
//
//  Created by John Haselden on 04/01/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONDocument: FileDocument {
    // Specify that this document is a JSON file
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    // Initializer for creating a new document from existing data
    init(data: Data) {
        self.data = data
    }

    // Required initializer for loading data (can be empty if you only export)
    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    // This function is called by the system to write the data to a file
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
