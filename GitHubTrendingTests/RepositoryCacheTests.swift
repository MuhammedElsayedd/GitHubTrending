//
//  RepositoryCacheTests.swift
//  GitHubTrendingTests
//
//  Created by Muhammed Elsayed on 17/11/2025.
//

import XCTest
@testable import GitHubTrending

final class RepositoryCacheTests: XCTestCase {
    var cache: RepositoryCache!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "test_cache") ?? UserDefaults.standard
        userDefaults.removePersistentDomain(forName: "test_cache")
        cache = RepositoryCache(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "test_cache")
        cache = nil
        userDefaults = nil
        super.tearDown()
    }
        
    private func makeTestRepository() -> RepositoryEntity {
        RepositoryEntity(
            id: 1,
            name: "TestRepo",
            fullName: "owner/TestRepo",
            description: "Test description",
            stars: 100,
            owner: OwnerEntity(login: "owner", avatarURL: "https://example.com/avatar.png"),
            htmlURL: "https://github.com/owner/TestRepo"
        )
    }
        
    func testSaveAndLoad_Success() {
        // Given
        let repositories = [makeTestRepository()]
        let query = "swift"
        
        // When
        cache.save(repositories, for: query)
        let loaded = cache.load(for: query)
        
        // Then
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.name, "TestRepo")
    }
    
    func testLoad_WithDifferentQuery_ReturnsNil() {
        // Given
        cache.save([makeTestRepository()], for: "swift")
        
        // When
        let loaded = cache.load(for: "kotlin")
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testLoad_WithNilQuery_ReturnsCachedData() {
        // Given
        cache.save([makeTestRepository()], for: "swift")
        
        // When
        let loaded = cache.load(for: nil)
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.count, 1)
    }
    
    
    func testGetTimestamp_ReturnsSavedTimestamp() {
        // Given
        let query = "swift"
        let beforeSave = Date()
        
        cache.save([makeTestRepository()], for: query)
        
        // When
        let timestamp = cache.getTimestamp(for: query)
        let afterSave = Date()
        
        // Then
        XCTAssertNotNil(timestamp)
        XCTAssertGreaterThanOrEqual(timestamp!, beforeSave)
        XCTAssertLessThanOrEqual(timestamp!, afterSave)
    }
    
    func testGetTimestamp_WithDifferentQuery_ReturnsNil() {
        // Given
        cache.save([makeTestRepository()], for: "swift")
        
        // When
        let timestamp = cache.getTimestamp(for: "kotlin")
        
        // Then
        XCTAssertNil(timestamp)
    }
    
    func testClear_RemovesAllCachedData() {
        // Given
        cache.save([makeTestRepository()], for: "swift")
        
        // When
        cache.clear()
        
        // Then
        XCTAssertNil(cache.load(for: nil))
        XCTAssertNil(cache.getTimestamp(for: nil))
    }
}
