//
//  RepositoryUIModel.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import Foundation
struct RepositoryUIModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stars: Int
    let starsFormatted: String
    let owner: OwnerUIModel
    let htmlURL: String
    
    init(from entity: RepositoryEntity) {
        self.id = entity.id ?? 0
        self.name = entity.name ?? "Unknown Repository"
        self.fullName = entity.fullName ?? "unknown/unknown"
        self.description = entity.description
        self.stars = entity.stars ?? 0
        self.starsFormatted = Self.formatStars(entity.stars ?? 0)
        if let owner = entity.owner {
            self.owner = OwnerUIModel(from: owner)
        } else {
            self.owner = OwnerUIModel(login: "unknown", avatarURL: "")
        }
        self.htmlURL = entity.htmlURL ?? ""
    }
    
    //MARK: Helper method to format star count
    private static func formatStars(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000.0)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000.0)
        } else {
            return "\(count)"
        }
    }
    
    func toEntity() -> RepositoryEntity {
        RepositoryEntity(
            id: id,
            name: name,
            fullName: fullName,
            description: description,
            stars: stars,
            owner: owner.toEntity(),
            htmlURL: htmlURL
        )
    }
}

struct OwnerUIModel: Equatable {
    let login: String
    let avatarURL: String
    let displayName: String
    
    init(from entity: OwnerEntity) {
        self.login = entity.login ?? "unknown"
        self.avatarURL = entity.avatarURL ?? ""
        self.displayName = "@\(entity.login ?? "unknown")"
    }
    
    init(login: String, avatarURL: String) {
        self.login = login
        self.avatarURL = avatarURL
        self.displayName = "@\(login)"
    }
    
    func toEntity() -> OwnerEntity {
        OwnerEntity(login: login, avatarURL: avatarURL)
    }
}

struct GitHubSearchResponseUIModel {
    let totalCount: Int
    let totalCountFormatted: String
    let repositories: [RepositoryUIModel]
    
    init(from entity: GitHubSearchResponseEntity) {
        self.totalCount = entity.totalCount ?? 0
        self.totalCountFormatted = Self.formatTotalCount(entity.totalCount ?? 0)
        self.repositories = (entity.items ?? [])
            .filter { ($0.id ?? 0) > 0 }
            .map { RepositoryUIModel(from: $0) }
    }
    
    //MARK: Helper method to format total count
    private static func formatTotalCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000.0)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000.0)
        } else {
            return "\(count)"
        }
    }
}

extension RepositoryUIModel {
    init(from mock: MockRepository) {
        self.id = mock.id
        self.name = mock.name
        self.fullName = "\(mock.ownerName)/\(mock.name)"
        self.description = mock.description
        self.stars = mock.stars
        self.starsFormatted = mock.starsFormatted
        self.owner = OwnerUIModel(
            login: mock.ownerName.replacingOccurrences(of: "@", with: ""),
            avatarURL: mock.ownerAvatarURL
        )
        self.htmlURL = "https://github.com/\(mock.ownerName)/\(mock.name)"
    }
}

struct MockRepository: Identifiable {
    let id: Int
    let name: String
    let description: String?
    let stars: Int
    let starsFormatted: String
    let ownerName: String
    let ownerAvatarURL: String
    
    static var sampleData: [MockRepository] {
        [
            MockRepository(
                id: 1,
                name: "swift",
                description: "The Swift Programming Language",
                stars: 65000,
                starsFormatted: "65K",
                ownerName: "@apple",
                ownerAvatarURL: "https://github.com/apple.png"
            ),
            MockRepository(
                id: 2,
                name: "Alamofire",
                description: "Elegant HTTP Networking in Swift",
                stars: 41000,
                starsFormatted: "41K",
                ownerName: "@Alamofire",
                ownerAvatarURL: "https://github.com/Alamofire.png"
            ),
            MockRepository(
                id: 3,
                name: "RxSwift",
                description: "Reactive Programming in Swift",
                stars: 24000,
                starsFormatted: "24K",
                ownerName: "@ReactiveX",
                ownerAvatarURL: "https://github.com/ReactiveX.png"
            ),
            MockRepository(
                id: 4,
                name: "Kingfisher",
                description: "A lightweight, pure-Swift library for downloading and caching images",
                stars: 22000,
                starsFormatted: "22K",
                ownerName: "@onevcat",
                ownerAvatarURL: "https://github.com/onevcat.png"
            ),
            MockRepository(
                id: 5,
                name: "SnapKit",
                description: "A Swift Autolayout DSL for iOS & OS X",
                stars: 20000,
                starsFormatted: "20K",
                ownerName: "@SnapKit",
                ownerAvatarURL: "https://github.com/SnapKit.png"
            )
        ]
    }
}
