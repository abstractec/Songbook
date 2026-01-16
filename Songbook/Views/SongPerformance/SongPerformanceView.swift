//
//  SongPerformanceView.swift
//  Songbook
//
//  Created by John Haselden on 15/01/2026.
//

import SwiftUI

struct SongPerformanceView: View {
    @State var viewModel: SongPerformanceViewModel
    
    var body: some View {
        VStack {
            switch viewModel.performanceStage {
            case .preSong:
                StartSongView(viewModel: viewModel)
            case .inSong:
                SectionPerformanceView(viewModel: viewModel)
            case .finished:
                FinishedView()
            }
        }
    }
}

struct StartSongView: View {
    @State var viewModel: SongPerformanceViewModel

    var body: some View {
        VStack {
            Text("Get ready to play \(viewModel.currentSongTitle)").font(.headline)
            Text("Original Artist: \(viewModel.currentSongArtist)")
            Text("Instrument: \(viewModel.currentSongPerformance?.instrument?.name ?? "")")

            if (viewModel.showChangeCapo) {
                HStack {
                    ChangeCapoView(capoPosition: viewModel.capoPosition)
                }
            }
            
            HStack {
                Button {
                    viewModel.perform()
                } label: {
                    Spacer()
                    Text("Go").font(.headline)
                        .foregroundStyle(Color.black)
                    Spacer()
                }
            }
            .frame(minHeight: 50)
            .background(Color.green)
            .border(Color.green, width: 4)
            .cornerRadius(8)
            .padding()
        }
    }
}

struct SectionPerformanceView: View {
    @State var viewModel: SongPerformanceViewModel

    var body: some View {
        VStack {
            HStack {
                
                Text(viewModel.render(section: viewModel.currentSection)).font(.body.monospaced())
                Spacer()
            }.padding()
            Spacer()
            
            Button {
                viewModel.nextSection()
            } label: {
                HStack {
                    Spacer()
                    Text("Next Section").font(.headline).foregroundStyle(.white)
                    Image(systemName: "chevron.right.dotted.chevron.right").foregroundStyle(.white)
                    Spacer()
                }
                .frame(minHeight: 50)
                .background(Color.blue)
                .border(Color.blue, width: 4)
                .cornerRadius(8)
                .padding()
            }
        }
    }
}

struct ChangeCapoView: View {
    var capoPosition: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            if (capoPosition == 0) {
                Text("Remove Capo").font(.headline)
            } else {
                Text("Change Capo to \(capoPosition)").font(.headline)
            }
            Spacer()
        }
        .frame(minHeight: 50)
        .background(Color.yellow)
        .border(Color.yellow, width: 4)
        .cornerRadius(8)
        .padding()
    }
}

struct FinishedView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Finished, thank you and good night!").font(.headline).foregroundStyle(.white)
                Spacer()
            }
            .frame(minHeight: 50)
            .background(Color.green)
            .border(Color.green, width: 4)
            .cornerRadius(8)
            .padding()
        }
    }
}


#Preview ("Start View"){
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1, repeats: 2)
    let song = Song(id: UUID(), title: "Song 1", sections: [])
    let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
    song.sections.append(section)
    
    let guitar = Instrument(id: UUID(), name: "Acoustic", strings: [])
    let guitar2 = Instrument(id: UUID(), name: "Guitar", strings: [])
    let guitar3 = Instrument(id: UUID(), name: "Guitar 3", strings: [])
    let bass = Instrument(id: UUID(), name: "Bass", strings: [])
    
    let instrumentConfiguration1 = InstrumentConfiguration(id: UUID(), name: "Capo at 3rd Fret", capoPosition: 3)
    let instrumentConfiguration2 = InstrumentConfiguration(id: UUID(), name: "Capo at 7th Fret", capoPosition: 7)
    
    guitar2.configurations = [instrumentConfiguration1, instrumentConfiguration2]
    
    let performance1 = SongPerformance(id: UUID(), song: song, instrument: guitar2, instrumentConfiguration: instrumentConfiguration1, position: 0)
    let performance2 = SongPerformance(id: UUID(), song: song, instrument: guitar2, instrumentConfiguration: instrumentConfiguration2, position: 1)

    let playlist = Playlist(id: UUID(), name: "Test", songPerformances: [performance1, performance2])
    let viewModel = SongPerformanceViewModel(playlist: playlist, modelContext: modelContainer.mainContext)
    return SongPerformanceView(viewModel: viewModel).modelContainer(modelContainer)
}

#Preview ("First Section View"){
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()

    let aMinor = Chord(id: UUID(), rootNote: .A, chordType: .minor)
    let cMajor = Chord(id: UUID(), rootNote: .C)

    let chordSequenceStep1 = ChordSequenceStep(id: UUID(), chord: aMinor, step: 0)
    let chordSequenceStep2 = ChordSequenceStep(id: UUID(), chord: cMajor, step: 17)

    let chordSequence1 = ChordSequence(id: UUID(), sequence: [chordSequenceStep1, chordSequenceStep2])

    let lyric = Lyric(id: UUID(), text: "This should be a line of lyrics")
    let phrase = Phrase(lyric: lyric, chordSequence: chordSequence1, repeats: 2)
    let song = Song(id: UUID(), title: "Song 1", sections: [])
    let section = Section(id: UUID(), name: "Verse 1", song: song, phrases: [phrase])
    song.sections.append(section)
    
    let guitar = Instrument(id: UUID(), name: "Acoustic", strings: [])
    let guitar2 = Instrument(id: UUID(), name: "Guitar", strings: [])
    let guitar3 = Instrument(id: UUID(), name: "Guitar 3", strings: [])
    let bass = Instrument(id: UUID(), name: "Bass", strings: [])
    
    let instrumentConfiguration1 = InstrumentConfiguration(id: UUID(), name: "Capo at 3rd Fret", capoPosition: 3)
    let instrumentConfiguration2 = InstrumentConfiguration(id: UUID(), name: "Capo at 7th Fret", capoPosition: 7)
    
    guitar2.configurations = [instrumentConfiguration1, instrumentConfiguration2]
    
    let performance1 = SongPerformance(id: UUID(), song: song, instrument: guitar2, instrumentConfiguration: instrumentConfiguration1, position: 0)
    let performance2 = SongPerformance(id: UUID(), song: song, instrument: guitar2, instrumentConfiguration: instrumentConfiguration2, position: 1)

    let playlist = Playlist(id: UUID(), name: "Test", songPerformances: [performance1, performance2])
    let viewModel = SongPerformanceViewModel(playlist: playlist, modelContext: modelContainer.mainContext)
    
    viewModel.perform()
    return SongPerformanceView(viewModel: viewModel).modelContainer(modelContainer)
}
