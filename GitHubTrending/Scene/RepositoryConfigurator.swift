//
//  RepositoryConfigurator.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 17/11/2025.
//

import Foundation
@MainActor
struct RepositoryConfigurator {
    static func create(
        searchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol? = nil,
        cache: RepositoryCacheProtocol? = nil,
        favoritesManager: FavoritesManagerProtocol? = nil
    ) -> RepositoryViewModel {
        let useCase = searchRepositoriesUseCase ?? SearchRepositoriesUseCase(
            networkService: NetworkService()
        )
        let repositoryCache = cache ?? RepositoryCache()
        let favorites = favoritesManager ?? FavoritesManager()
        
        return RepositoryViewModel(
            searchRepositoriesUseCase: useCase,
            cache: repositoryCache,
            favoritesManager: favorites
        )
    }
}
