//
//  PhraseViewModel.swift
//  Songbook
//
//  Created by John Haselden on 02/03/2026.
//

import SwiftUI

@Observable
class PhraseViewModel {
    var phrase: Phrase

    init(phrase: Phrase) {
        self.phrase = phrase
    }
        
    @ViewBuilder
    func render(phrase: Phrase) -> some View {
        let songRenderer = SwiftUISongRenderer()
        
        songRenderer.render(phrase: phrase)
    }

}
