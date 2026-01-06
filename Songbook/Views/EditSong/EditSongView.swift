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
    @Environment(\.dismiss) var dismiss
    
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
                Text("Artist").font(.headline).frame(minWidth: 100, alignment: .leading)
                TextField("Enter Artist Name", text: $viewModel.artist)
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
        
        ForEach(viewModel.sections) { section in
        }
        
        Button("Save Song") {
            viewModel.save()
            dismiss()
        }
    }
}

#Preview {
    let editSongViewModel = EditSongViewModel(song: nil)
    
    EditSongView(viewModel: editSongViewModel)
}
