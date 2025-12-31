//
//  SectionViewModel.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import Foundation

@Observable
class SongViewModel: Identifiable {
    var name: String = ""
    var section: Section?
    
    init(section: Section) {
        self.section = section
    }
}
