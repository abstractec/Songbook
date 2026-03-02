//
//  PhraseView.swift
//  Songbook
//
//  Created by John Haselden on 02/03/2026.
//

import SwiftUI

struct PhraseView: View {
    var viewModel: PhraseViewModel
    
    var body: some View {
        VStack {
            HStack {
                viewModel.render(phrase: viewModel.phrase)
                Spacer()
            }
        }
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let song = Song(id: UUID(), title: "Test Song", sections: [])
    let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [])
    let section2 = Section(id: UUID(), name: "Verse 2", song: song, phrases: [])

    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let gMajor = Chord(id: UUID(), rootNote: .G)
    let dMajor = Chord(id: UUID(), rootNote: .D)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 7)
    let chordSequenceStep3 = ChordSequenceStep(id: UUID(), chord: gMajor, step: 9)
    let chordSequenceStep4 = ChordSequenceStep(id: UUID(), chord: dMajor, step: 16)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])
    let chordSequence2 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep3, chordSequenceStep4])

    let lyric1 = Lyric(id: UUID(), text: "I am a lyric")
    let lyric2 = Lyric(id: UUID(), text: "I am the second line")
    
    let phrase1 = Phrase(id: UUID(), chordSequence: chordSequence1)
    phrase1.lyric = lyric1
    
    let viewModel = PhraseViewModel(phrase: phrase1)
    
    return PhraseView(viewModel: viewModel)
}
