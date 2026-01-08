//
//  EditInstrumentView.swift
//  Songbook
//
//  Created by John Haselden on 07/01/2026.
//

import SwiftUI

struct EditInstrumentView: View {
    @State var viewModel: EditInstrumentViewModel
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Name").font(.headline).frame(minWidth: 100, alignment: .leading)
                TextField("Enter Song Name", text: $viewModel.name)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 0)
        }
    }
}

#Preview {
    let viewModel = EditInstrumentViewModel()
    
    EditInstrumentView(viewModel: viewModel)
}
