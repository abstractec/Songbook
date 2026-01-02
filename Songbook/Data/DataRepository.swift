//
//  DataRepository.swift
//  Songbook
//
//  Created by John Haselden on 02/01/2026.
//

import Foundation
import SwiftData

class DataRepository {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func loadItems<T>(fetchDescriptor: FetchDescriptor<T>) -> [T] where T: PersistentModel {
        var items: [T] = []
            
        do {
            items = try modelContext.fetch(fetchDescriptor)
            
            // 3. Process the results (e.g., update UI, print to console).
        } catch {
            // 4. Handle any potential errors during the fetch.
            print("Failed to load models: \(error.localizedDescription)")
        }
        
        return items

    }

}
