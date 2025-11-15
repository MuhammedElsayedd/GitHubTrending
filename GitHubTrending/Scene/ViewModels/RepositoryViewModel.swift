//
//  RepositoryViewModel.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation

protocol RepositoryViewModelProtocol: Observable {
    var repositories: [RepositoryUIModel] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var isOffline: Bool { get }
    var searchQuery: String { get set }
    var currentPage: Int { get }
    var hasMorePages: Bool { get }
    var isRefreshing: Bool { get }
    
    func loadInitialData() async
    func performSearch(query: String, page: Int) async
    func refresh() async
    func loadMoreIfNeeded() async
}

@Observable
final class RepositoryViewModel: RepositoryViewModelProtocol {
    var repositories: [RepositoryUIModel] = []
    var isLoading = false
    var errorMessage: String?
    var isOffline = false
    var searchQuery = "" {
        didSet {
            Task {
                await handleSearchQueryChange()
            }
        }
    }
    var currentPage = 1
    var hasMorePages = true
    var isRefreshing = false
    
    private let searchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol
    private let defaultQuery = "language:swift"
    private var searchTask: Task<Void, Never>?
    
    init(
        searchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol
    ) {
        self.searchRepositoriesUseCase = searchRepositoriesUseCase
    }
    
    private func handleSearchQueryChange() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            let query = searchQuery.isEmpty ? defaultQuery : searchQuery
            await performSearch(query: query, page: 1)
        }
    }
    
    @MainActor
    func loadInitialData() async {
        await performSearch(query: defaultQuery)
    }
    
    func performSearch(query: String, page: Int = 1) async {
        guard !query.isEmpty else { return }
        
        isLoading = page == 1
        errorMessage = nil
        isRefreshing = page == 1
        
        do {
            let response = try await searchRepositoriesUseCase.execute(query: query, page: page, perPage: 30)
            
            if page == 1 {
                repositories = response.repositories
                isOffline = false
            } else {
                repositories.append(contentsOf: response.repositories)
            }
            
            hasMorePages = response.repositories.count == 30 && (page * 30) < response.totalCount && response.totalCount > 0
            currentPage = page
            
            isLoading = false
            isRefreshing = false
        } catch {
            errorMessage = error.localizedDescription
            repositories = []
            isLoading = false
            isRefreshing = false
        }
    }
    
    func refresh() async {
        let query = searchQuery.isEmpty ? defaultQuery : searchQuery
        await performSearch(query: query, page: 1)
    }
    
    func loadMoreIfNeeded() async {
        guard !isLoading && hasMorePages && !isRefreshing else { return }
        
        let query = searchQuery.isEmpty ? defaultQuery : searchQuery
        await performSearch(query: query, page: currentPage + 1)
    }
}
