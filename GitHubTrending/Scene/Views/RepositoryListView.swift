//
//  RepositoryListView.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

struct RepositoryListView: View {
    @State var viewModel: RepositoryViewModelProtocol
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBarView(text: $viewModel.searchQuery)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if viewModel.isOffline {
                    OfflineIndicatorView(message: "Using cached data - Offline mode")
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                if let errorMessage = viewModel.errorMessage, !viewModel.isOffline {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if viewModel.repositories.isEmpty && !viewModel.isLoading {
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
                            ForEach(viewModel.repositories) { repository in
                                RepositoryCardView(
                                    repository: repository,
                                    isFavorite: viewModel.isFavorite(repository),
                                    onFavoriteToggle: {
                                        viewModel.toggleFavorite(repository)
                                    }
                                )
                                .onAppear {
                                    if repository.id == viewModel.repositories.last?.id {
                                        Task {
                                            await viewModel.loadMoreIfNeeded()
                                        }
                                    }
                                }
                            }
                            
                            if viewModel.isLoading && viewModel.currentPage > 1 {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
                
                if viewModel.isLoading && viewModel.repositories.isEmpty {
                    ProgressView("Loading repositories...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("GitHub Repositories")
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
}

#Preview {
    RepositoryListView(viewModel: RepositoryViewModelMock())
}
