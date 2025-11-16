//
//  RepositoryCache.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 16/11/2025.
//

import Foundation

struct CachedRepositories: Codable {
    let repositories: [RepositoryEntity]
    let query: String
    let timestamp: Date
}

protocol RepositoryCacheProtocol {
    func save(_ repositories: [RepositoryEntity], for query: String)
    func load(for query: String?) -> [RepositoryEntity]?
    func getTimestamp(for query: String?) -> Date?
    func clear()
}

class RepositoryCache: RepositoryCacheProtocol {
    private let userDefaults: UserDefaults
    private let cacheKey = "cached_repositories"
    private let timestampKey = "cache_timestamp"
    private let queryKey = "cache_query"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(_ repositories: [RepositoryEntity], for query: String) {
        let cached = CachedRepositories(
            repositories: repositories,
            query: query,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(cached) {
            userDefaults.set(encoded, forKey: cacheKey)
            userDefaults.set(query, forKey: queryKey)
            userDefaults.set(Date(), forKey: timestampKey)
        }
    }
    
    func load(for query: String?) -> [RepositoryEntity]? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedRepositories.self, from: data) else {
            return nil
        }
        
        if let query = query, cached.query != query {
            return nil
        }
        
        return cached.repositories
    }
    
    func getTimestamp(for query: String?) -> Date? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedRepositories.self, from: data) else {
            return nil
        }
        
        if let query = query, cached.query != query {
            return nil
        }
        
        return cached.timestamp
    }
    
    func clear() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: queryKey)
        userDefaults.removeObject(forKey: timestampKey)
    }
}
