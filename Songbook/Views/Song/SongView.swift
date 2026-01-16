//
//  SongView.swift
//  Songbook
//
//  Created by John Haselden on 31/12/2025.
//

import SwiftUI
import SwiftData

struct SongView: View {
    @State var viewModel: SongViewModel
    @Query(sort: \Instrument.name) private var instruments: [Instrument]
    
    var body: some View {
        VStack {
            
            ScrollView {
                VStack {
                    Text(viewModel.song.title)
                        .font(.headline)
                    
                    HStack {
                        Text("Instrument")
                        Spacer()
                        Picker("Instrument", selection: $viewModel.instrumentAndConfig) {
                            ForEach(viewModel.instrumentAndConfigurationList(for: instruments)) { instrumentConfig in
                                Text(viewModel.name(for: instrumentConfig.instrument, with: instrumentConfig.config))
                                    .tag(instrumentConfig) // Important to set the tag to the actual enum case
                            }
                        }.onChange(of: viewModel.instrumentAndConfig) { oldValue, newValue in
                            if let instrumentConfig = newValue {
                                viewModel.transpose(instrumentConfiguration: instrumentConfig)
                            }
                        }

                    }.padding(.horizontal)
                    
                    if (viewModel.showKey) {
                        HStack {
                            Text("Key")
                            Text(viewModel.key)
                            Spacer()
                        }.padding(.horizontal)
                    }
                    
                    if (viewModel.showCapo) {
                        HStack {
                            Text("Capo")
                            Text(viewModel.capo)
                            Spacer()
                        }.padding(.horizontal)
                    }
                    
                    ForEach(viewModel.song.sections.sorted(by: { $0.position < $1.position })) { section in
                        VStack {
                            HStack(spacing:0) {
                                VStack{
                                    HStack {
                                        Text(section.name)
                                        Spacer()
                                    }
                                    
                                    ForEach(section.phrases.sorted{ $0.position < $1.position }) { phrase in
                                        HStack() {
                                            Text("\(viewModel.render(phrase: phrase))").font(.body.monospaced())
                                            Spacer()
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 2)
                                    }
                                }
                            }
                            
                        }
                        if (viewModel.inEditMode) {
                            HStack {
                                Button(action: {
                                    viewModel.moveUp(section: section)
                                }) {
                                    Image(systemName: "arrowshape.up")
                                        .frame(width: 10, height: 10, alignment: .center)
                                }.padding(.horizontal)
                                
                                Button(action: {
                                    viewModel.moveDown(section: section)
                                }) {
                                    Image(systemName: "arrowshape.down")
                                        .frame(width: 10, height: 10, alignment: .center)
                                }.padding(.horizontal)
                                Button {
                                    viewModel.duplicate(section: section)
                                } label: {
                                    Image(systemName: "document.on.document")
                                        .frame(width: 10, height: 10, alignment: .center)
                                    
                                }.padding(.horizontal, 4)
                                
                                Button(action: {
                                    viewModel.addSection(after: section)
                                }) {
                                    Image(systemName: "plus.app")
                                        .frame(width: 10, height: 10, alignment: .center)
                                }.padding(.horizontal)
                                
                                NavigationLink(value: DetailDestination.editSection(section: section)) {
                                    Image(systemName: "square.and.pencil")
                                        .frame(width: 10, height: 10, alignment: .center)
                                }.padding(.horizontal)
                                Button {
                                    viewModel.delete(section: section)
                                } label: {
                                    Image(systemName: "trash")
                                        .frame(width: 10, height: 10, alignment: .center)
                                        .foregroundStyle(.red)
                                    
                                }.padding(.horizontal, 4)
                                
                            }
                        }
                        
                    }.padding()
                }
                
                if (viewModel.inEditMode) {
                    NavigationLink(value: DetailDestination.newSection(song: viewModel.song)) {
                        Text("Add Section")
                    }
                }
                
                Button {
                    viewModel.exportSong()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                    Text("Export Song")
                }.padding(.leading, 2)
                    .fileExporter(
                        isPresented: $viewModel.isExporting,
                        document: viewModel.document,
                        contentType: .json,
                        defaultFilename: viewModel.exportFilename
                    ) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to: \(url)")
                        case .failure(let error):
                            print("Export failed: \(error.localizedDescription)")
                        }
                    }
                Button("Edit Song") {
                    viewModel.toggleEditMode()
                }
            }
            HStack() {
                Text("Transpose")
                Button {
                    viewModel.decreaseTransposition()
                } label: {
                    Image(systemName: "arrowtriangle.down")
                }
                Button {
                    viewModel.increaseTransposition()
                } label: {
                    Image(systemName: "arrowtriangle.up")
                }

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

    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: chordSequence1))
    
    section.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: chordSequence2))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am a lyric"),
                                  chordSequence: chordSequence1))
    
    section2.phrases.append(Phrase(id: UUID(),
                                  sections: [],
                                  lyric: Lyric(id: UUID(), text: "I am the second line"),
                                  chordSequence: chordSequence2))

    song.sections.append(section)
    song.sections.append(section2)
    song.key = "C Major"
    
    let viewModel = SongViewModel(song: song, modelContext: nil)
    
    let guitarStrings = [
        InstrumentString(id: UUID(), note: .E, position: 6),
        InstrumentString(id: UUID(), note: .A, position: 5),
        InstrumentString(id: UUID(), note: .D, position: 4),
        InstrumentString(id: UUID(), note: .G, position: 3),
        InstrumentString(id: UUID(), note: .B, position: 2),
        InstrumentString(id: UUID(), note: .E, position: 1),
    ]

    let guitarStrings2 = [
        InstrumentString(id: UUID(), note: .E, position: 6),
        InstrumentString(id: UUID(), note: .A, position: 5),
        InstrumentString(id: UUID(), note: .D, position: 4),
        InstrumentString(id: UUID(), note: .G, position: 3),
        InstrumentString(id: UUID(), note: .B, position: 2),
        InstrumentString(id: UUID(), note: .E, position: 1),
    ]

    let bassStrings = [
        InstrumentString(id: UUID(), note: .E, position: 4),
        InstrumentString(id: UUID(), note: .A, position: 3),
        InstrumentString(id: UUID(), note: .D, position: 2),
        InstrumentString(id: UUID(), note: .G, position: 1),
    ]
    
    let guitar = Instrument(id: UUID(), name: "Acoustic", strings: guitarStrings)
    let guitar2 = Instrument(id: UUID(), name: "Guitar", strings: guitarStrings2)
    let guitar3 = Instrument(id: UUID(), name: "Guitar 3", strings: guitarStrings2)
    let bass = Instrument(id: UUID(), name: "Bass", strings: bassStrings)
    
    let instrumentConfiguration1 = InstrumentConfiguration(id: UUID(), name: "Capo at 3rd Fret", capoPosition: 3)
    let instrumentConfiguration2 = InstrumentConfiguration(id: UUID(), name: "Capo at 7th Fret", capoPosition: 7)
    
    guitar2.configurations = [instrumentConfiguration1, instrumentConfiguration2]

    modelContainer.mainContext.insert(guitar)
    modelContainer.mainContext.insert(guitar2)
    modelContainer.mainContext.insert(guitar3)
    modelContainer.mainContext.insert(bass)
    
    return SongView(viewModel: viewModel).modelContainer(modelContainer)
}
