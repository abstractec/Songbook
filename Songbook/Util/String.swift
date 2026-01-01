//
//  String.swift
//  Songbook
//
//  Created by John Haselden on 14/12/2025.
//

import Foundation

extension String {
    func split(by length: Int) -> [String] {
        guard length > 0 else { return [] }
        var result: [String] = []
        let indices = self.indices
        var currentStartIndex = indices.startIndex
        
        while currentStartIndex < indices.endIndex {
            let endIndex = self.index(currentStartIndex, offsetBy: length, limitedBy: indices.endIndex) ?? indices.endIndex
            let substring = self[currentStartIndex..<endIndex]
            result.append(String(substring))
            currentStartIndex = endIndex
        }
        
        return result
    }

    func findNextWhitespace(from index: String.Index) -> String.Index? {
        // Iterate through the string's indices starting from the specified index
        return self[index...].firstIndex(where: { $0.isWhitespace })
    }
}
