//
//  SearchableView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/16/24.
//

import SwiftUI

struct SearchableView: ViewModifier {
    @Binding var searchText: String

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search...", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            )
    }
}

extension View {
    func searchable(searchText: Binding<String>) -> some View {
        self.modifier(SearchableView(searchText: searchText))
    }
}
