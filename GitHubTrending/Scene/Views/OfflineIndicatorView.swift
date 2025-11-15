//
//  OfflineIndicatorView.swift
//  GitHubTrending
//
//  Created by Muhammed Elsayed on 15/11/2025.
//

import SwiftUI

struct OfflineIndicatorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    OfflineIndicatorView(message: "Using cached data")
}
