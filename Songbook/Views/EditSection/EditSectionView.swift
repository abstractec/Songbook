//
//  EditSectionView.swift
//  Songbook
//
//  Created by John Haselden on 13/12/2025.
//

import SwiftUI

struct EditSectionView: View {
    @State var viewModel: SectionViewModel
    @State private var path = NavigationPath()

    var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        Text("Name").font(.headline).frame(minWidth: 100, alignment: .leading)
                        TextField("Enter Section Name", text: $viewModel.name)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                }
                

                
//                ForEach(viewModel.sections) { section in
//                }

                if let section = viewModel.section {
                    NavigationLink(value: DetailDestination.newPhrase(section: section)) {
                        Text("Add Phrase")
                    }
                }
                
                HStack {
                    Spacer()
                    Button("Save") {
                        viewModel.save()
                    }

                    Spacer()
                }.padding(.top, 16)
            }
            .navigationTitle("Edit Section")
            .navigationDestination(for: Bool.self) { item in
            }
        }
    }

#Preview {
    var song = Song.emptySong
    var viewModel = SectionViewModel(song: song, section: nil)

    EditSectionView(viewModel: viewModel)
}
