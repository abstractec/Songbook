//
//  EditSongView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI

struct EditSongView: View {
    @State var viewModel: EditSongViewModel
    @State private var showAddSection = false
    @State private var path = NavigationPath()
    
    var body: some View {
                VStack {
                    HStack {
                        Text("Name").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Song Name", text: $viewModel.name)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                }
                
                VStack {
                    HStack {
                        Text("Key").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Song Key", text: $viewModel.key)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                }
                
                VStack {
                    HStack {
                        Text("Capo").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Song Capo", text: $viewModel.capo)
                            .onChange(of: viewModel.capo) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    viewModel.capo = filtered
                                }
                            }
#if os(iOS)
                            .keyboardType(.numberPad)
#endif
                        Spacer()
                    }
                    .padding(.vertical, 0)
                    .padding(.horizontal)
                }
                
                ForEach(viewModel.sections) { section in
                }
                
        if let song = viewModel.song {
            NavigationLink(value: DetailDestination.newSection(song: song)) {
                Text("Add Section")
            }
            .navigationTitle("Edit Song")
            .navigationDestination(for: Bool.self) { item in
                let viewModel = SectionViewModel(song: song, section: nil)
                EditSectionView(viewModel: viewModel)
//                EditSectionView(viewModel: item as! SectionViewModel)
            }

        }
    }
}

#Preview {
    let editSongViewModel = EditSongViewModel(song: nil)
    
    EditSongView(viewModel: editSongViewModel)
}
