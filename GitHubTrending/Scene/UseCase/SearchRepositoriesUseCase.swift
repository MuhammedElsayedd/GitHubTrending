//
//  SearchRepositoriesUseCase.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation
protocol SearchRepositoriesUseCaseProtocol {
    func execute(query: String, page: Int, perPage: Int) async throws -> GitHubSearchResponseUIModel
}

class SearchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func execute(query: String, page: Int, perPage: Int) async throws -> GitHubSearchResponseUIModel {
        let entity = try await networkService.searchRepositories(query: query, page: page, perPage: perPage)
        
        return GitHubSearchResponseUIModel(from: entity)
    }
}

