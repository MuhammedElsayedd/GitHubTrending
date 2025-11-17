# GitHubTrending

A SwiftUI-based iOS application that displays trending GitHub repositories with search functionality, offline support, and additional features.


1. **Main Screen**
   - Search bar at the top for searching GitHub repositories
   - List of repository cards displaying trending repositories by default or search results

2. **Repository Card**
   - Repository title
   - Repository description
   - Star count
   - Owner avatar image

3. **Networking**
   - Uses GitHub Search API: `GET https://api.github.com/search/repositories?q=<query>`
   - Proper error handling and network error management

4. **Caching / Offline Support**
   - Caches the last successful list of repositories locally using UserDefaults
   - Displays cached repositories when offline or on network error
   - Shows visible "offline" or "cached" indicator when using cached data

5. **User Experience**
   - Pull-to-refresh functionality to fetch fresh data
   - Loading states and error messages
   - Visible offline/cached indicator

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

### Key Components

#### 1. NetworkService
- Handles all GitHub API calls
- Uses async/await for modern Swift concurrency
- Comprehensive error handling with custom `NetworkError` enum
- Protocol-based design for testability

#### 2. RepositoryCache
- Stores repositories using UserDefaults with Codable encoding
- Maintains query association for proper cache retrieval
- Stores timestamps for cache freshness tracking
- Protocol-based for easy testing and mocking

#### 3. RepositoryViewModel
- Manages app state (loading, error, offline status)
- Handles search with debouncing (500ms delay)
- Implements pagination logic
- Coordinates between network service and cache
- Handles offline fallback automatically

