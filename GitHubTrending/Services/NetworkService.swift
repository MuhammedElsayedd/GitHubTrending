//
//  NetworkService.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func searchRepositories(query: String, page: Int, perPage: Int) async throws -> GitHubSearchResponseEntity
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.github.com"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchRepositories(query: String, page: Int = 1, perPage: Int = 30) async throws -> GitHubSearchResponseEntity {
        guard let url = URL(string: "\(baseURL)/search/repositories?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&page=\(page)&per_page=\(perPage)") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(NSError(domain: "NetworkService", code: -1))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(GitHubSearchResponseEntity.self, from: data)
            
            return searchResponse
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}

