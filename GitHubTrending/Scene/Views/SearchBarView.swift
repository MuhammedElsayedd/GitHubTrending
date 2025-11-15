//
//  SearchBarView.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search repositories...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .accessibilityIdentifier("searchTextField")
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .accessibilityIdentifier("clearSearchButton")
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search repositories")
    }
}

#Preview {
    SearchBarView(text: .constant(""))
        .padding()
}
