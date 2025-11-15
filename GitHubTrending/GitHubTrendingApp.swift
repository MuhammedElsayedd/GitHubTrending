//
//  GitHubTrendingApp.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

@main
struct GitHubTrendingApp: App {
    var body: some Scene {
        WindowGroup {
            let networkService = NetworkService()
            let useCase = SearchRepositoriesUseCase(networkService: networkService)
            let viewModel = RepositoryViewModel(searchRepositoriesUseCase: useCase)

            RepositoryListView(viewModel: viewModel)
        }
    }
}
