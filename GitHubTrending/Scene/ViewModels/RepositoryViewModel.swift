//
//  RepositoryViewModel.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation
import Observation
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
    func isFavorite(_ repository: RepositoryUIModel) -> Bool
    func toggleFavorite(_ repository: RepositoryUIModel)
}

@MainActor
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
    private var favoritesUpdateCounter = 0
    
    private let searchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol
    private let cache: RepositoryCacheProtocol
    private let favoritesManager: FavoritesManagerProtocol
    private let defaultQuery = "language:swift"
    private var searchTask: Task<Void, Never>?
    
    init(
        searchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol,
        cache: RepositoryCacheProtocol,
        favoritesManager: FavoritesManagerProtocol
    ) {
        self.searchRepositoriesUseCase = searchRepositoriesUseCase
        self.cache = cache
        self.favoritesManager = favoritesManager
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
                cache.save(response.repositories.map { $0.toEntity() }, for: query)
                isOffline = false
            } else {
                repositories.append(contentsOf: response.repositories)
            }
            
            hasMorePages = response.repositories.count == 30 && (page * 30) < response.totalCount && response.totalCount > 0
            currentPage = page
            
            isLoading = false
            isRefreshing = false
        } catch {
            if let cachedEntities = cache.load(for: query.isEmpty ? nil : query) {
                repositories = cachedEntities.map { RepositoryUIModel(from: $0) }
                isOffline = true
                errorMessage = "Using cached data. \(error.localizedDescription)"
            } else {
                errorMessage = error.localizedDescription
                repositories = []
            }
            
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
    
    func isFavorite(_ repository: RepositoryUIModel) -> Bool {
        _ = favoritesUpdateCounter
        return favoritesManager.isFavorite(repository.toEntity())
    }
    
    func toggleFavorite(_ repository: RepositoryUIModel) {
        favoritesManager.toggleFavorite(repository.toEntity())
        favoritesUpdateCounter += 1
    }
}
