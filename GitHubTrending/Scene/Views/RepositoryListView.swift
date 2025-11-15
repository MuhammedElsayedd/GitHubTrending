//
//  RepositoryListView.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

struct RepositoryListView: View {
    @State private var searchText = ""
    @State private var repositories: [RepositoryUIModel] =
        MockRepository.sampleData.map { RepositoryUIModel(from: $0) }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search repositories...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if repositories.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No repositories found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(repositories) { repository in
                                RepositoryCardView(
                                    repository: repository,
                                    isFavorite: true,
                                    onFavoriteToggle: {},
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("GitHub Repositories")
        }
    }
}

#Preview {
    RepositoryListView()
}
