//
//  Array.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import Foundation

extension Array {
    /**
     Moves an element within the array from a source index to a destination index.
     
     - Parameters:
       - from sourceIndex: The index of the element to move.
       - to destinationIndex: The new index for the element.
     */
    mutating func move(from sourceIndex: Int, to destinationIndex: Int) {
        // Ensure the indices are valid and different
        guard sourceIndex != destinationIndex,
              sourceIndex >= 0, sourceIndex < count,
              destinationIndex >= 0, destinationIndex < count
        else {
            return
        }
        
        let element = remove(at: sourceIndex)
        insert(element, at: destinationIndex)
    }
}
