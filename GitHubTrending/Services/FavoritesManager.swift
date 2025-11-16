//
//  FavoritesManager.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 16/11/2025.
//

import Foundation

protocol FavoritesManagerProtocol {
    func isFavorite(_ repository: RepositoryEntity) -> Bool
    func toggleFavorite(_ repository: RepositoryEntity)
    func getFavorites() -> [RepositoryEntity]
}

class FavoritesManager: FavoritesManagerProtocol {
    private let userDefaults: UserDefaults
    private let favoritesKey = "favorite_repositories"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func isFavorite(_ repository: RepositoryEntity) -> Bool {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([RepositoryEntity].self, from: data) else {
            return false
        }
        return favorites.contains(where: { $0.id == repository.id })
    }
    
    func toggleFavorite(_ repository: RepositoryEntity) {
        var favorites = getFavorites()
        
        if let index = favorites.firstIndex(where: { $0.id == repository.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(repository)
        }
        
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func getFavorites() -> [RepositoryEntity] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([RepositoryEntity].self, from: data) else {
            return []
        }
        return favorites
    }
}

