//
//  GitHubSearchResponseEntity.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation

struct GitHubSearchResponseEntity: Codable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [RepositoryEntity]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct RepositoryEntity: Codable, Equatable {
    let id: Int?
    let name: String?
    let fullName: String?
    let description: String?
    let stars: Int?
    let owner: OwnerEntity?
    let htmlURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case description
        case stars = "stargazers_count"
        case owner
        case htmlURL = "html_url"
    }
}

struct OwnerEntity: Codable, Equatable {
    let login: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
    }
}
