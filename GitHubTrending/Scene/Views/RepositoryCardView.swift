//
//  RepositoryCardView.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

struct RepositoryCardView: View {
    let repository: RepositoryUIModel
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    @State private var avatarImage: UIImage?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: repository.owner.avatarURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(repository.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: onFavoriteToggle) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                    }
                    .accessibilityIdentifier("favoriteButton_\(repository.id)")
                    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label(repository.starsFormatted, systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(repository.owner.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Repository: \(repository.name)")
    }
}

#Preview {
    let entity = RepositoryEntity(
        id: 1,
        name: "Sample Repo",
        fullName: "owner/sample-repo",
        description: "This is a sample repository description",
        stars: 1234,
        owner: OwnerEntity(login: "owner", avatarURL: "https://github.com/github.png"),
        htmlURL: "https://github.com"
    )
    return RepositoryCardView(
        repository: RepositoryUIModel(from: entity),
        isFavorite: false,
        onFavoriteToggle: {}
    )
    .padding()
}
