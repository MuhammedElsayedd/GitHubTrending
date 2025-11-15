//
//  RepositoryViewModelMock.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation

final class RepositoryViewModelMock: RepositoryViewModelProtocol {

    var repositories: [RepositoryUIModel]
    var isLoading: Bool = false
    var errorMessage: String?
    var isOffline: Bool = false
    var searchQuery: String = ""
    var currentPage: Int = 1
    var hasMorePages: Bool = false
    var isRefreshing: Bool = false

    init() {
        self.repositories = MockRepository.sampleData.map { RepositoryUIModel(from: $0) }
    }

    func loadInitialData() async {}

    func performSearch(query: String, page: Int) async {
        if query.isEmpty {
            repositories = MockRepository.sampleData.map { RepositoryUIModel(from: $0) }
        } else {
            repositories = MockRepository.sampleData
                .filter { $0.name.lowercased().contains(query.lowercased()) }
                .map { RepositoryUIModel(from: $0) }
        }
    }

    func refresh() async {
        isRefreshing = true
        await loadInitialData()
        isRefreshing = false
    }

    func loadMoreIfNeeded() async {
        hasMorePages = false
    }
}
