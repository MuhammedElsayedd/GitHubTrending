//
//  NetworkServiceTests.swift
//  GitHubTrendingTests
//
//  Created by Muhammed Elsayed on 17/11/2025.
//

import XCTest
@testable import GitHubTrending

final class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        networkService = NetworkService(session: mockSession)
        MockURLProtocol.requestHandler = nil
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        networkService = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Case
    @MainActor
    func testSearchRepositories_Success() async throws {
        // Given
        let expectedRepo = RepositoryEntity(
            id: 1,
            name: "TestRepo",
            fullName: "owner/TestRepo",
            description: "Test description",
            stars: 100,
            owner: OwnerEntity(login: "owner", avatarURL: "https://example.com/avatar.png"),
            htmlURL: "https://github.com/owner/TestRepo"
        )
        
        let response = GitHubSearchResponseEntity(
            totalCount: 1,
            incompleteResults: false,
            items: [expectedRepo]
        )
        
        let jsonData = try JSONEncoder().encode(response)
        
        MockURLProtocol.requestHandler = { _ in
            let httpResponse = HTTPURLResponse(
                url: URL(string: "https://api.github.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, jsonData)
        }
        
        // When
        let result = try await networkService.searchRepositories(query: "swift")
        
        // Then
        XCTAssertEqual(result.items?.count, 1)
        XCTAssertEqual(result.items?.first?.name, "TestRepo")
    }
    
    // MARK: - Error Cases
    func testSearchRepositories_NetworkError() async {
        // Given
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        // When/Then
        do {
            _ = try await networkService.searchRepositories(query: "swift")
            XCTFail("Expected network error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testSearchRepositories_HTTPError() async {
        // Given
        MockURLProtocol.requestHandler = { _ in
            let httpResponse = HTTPURLResponse(
                url: URL(string: "https://api.github.com")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, Data())
        }
        
        // When/Then
        do {
            _ = try await networkService.searchRepositories(query: "swift")
            XCTFail("Expected HTTP error")
        } catch {
            if case NetworkError.httpError(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Expected httpError, got \(error)")
            }
        }
    }
    
    func testSearchRepositories_DecodingError() async {
        // Given
        let invalidData = "invalid json".data(using: .utf8)!
        MockURLProtocol.requestHandler = { _ in
            let httpResponse = HTTPURLResponse(
                url: URL(string: "https://api.github.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (httpResponse, invalidData)
        }
        
        // When/Then
        do {
            _ = try await networkService.searchRepositories(query: "swift")
            XCTFail("Expected decoding error")
        } catch {
            if case NetworkError.decodingError = error {
                // Success
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        }
    }
}

// MARK: - Mock URL Protocol

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: -1))
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
}
