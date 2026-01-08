//
//  InstrumentsView.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

import SwiftUI
import SwiftData

struct InstrumentsView: View {
    @Query(sort: \Instrument.name) var instruments: [Instrument]
    
    @State var viewModel: InstrumentsViewModel

    var body: some View {
        VStack {
            ScrollView {
                ForEach(instruments) { instrument in
                    InstrumentRow(instrument: instrument, viewModel: viewModel)
                }
                
            }
            
            NavigationLink(value: DetailDestination.newInstrument) {
                Image(systemName: "pianokeys")
                Text("New Instrument")
            }
        }
    }
}

struct InstrumentRow: View {
    var instrument: Instrument
    @State var viewModel: InstrumentsViewModel

    
    var body: some View {
        HStack {
            Text(viewModel.render(instrument: instrument))
            Spacer()
        }.padding(.horizontal)
    }
}

#Preview {
    let dataHelper = DataHelper()
    let modelContainer = dataHelper.mockModelContainer()
    
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
    let guitar2 = Instrument(id: UUID(), name: "Guitar", strings: guitarStrings2, capo: 3)
    let bass = Instrument(id: UUID(), name: "Bass", strings: bassStrings)

    modelContainer.mainContext.insert(guitar)
    modelContainer.mainContext.insert(guitar2)
    modelContainer.mainContext.insert(bass)
    
  
    let viewModel = InstrumentsViewModel()
    
    return InstrumentsView(viewModel: viewModel).modelContainer(modelContainer)
}
