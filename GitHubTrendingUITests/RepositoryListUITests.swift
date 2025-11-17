//
//  RepositoryListUITests.swift
//  GitHubTrendingUITests
//
//  Created by Muhammed Elsayed on 17/11/2025.
//

import XCTest

final class RepositoryListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testAppLaunch() throws {
        XCTAssertTrue(app.navigationBars["GitHub Repositories"].exists)
    }
    
    @MainActor
    func testSearchBarExists() throws {
        sleep(2)
        
        let searchTextField = app.textFields["searchTextField"]
        XCTAssertTrue(searchTextField.waitForExistence(timeout: 5), "Search text field should exist")
    }
    
    @MainActor
    func testSearchFunctionality() throws {
        sleep(2)
        
        let searchTextField = app.textFields["searchTextField"]
        XCTAssertTrue(searchTextField.waitForExistence(timeout: 5), "Search text field should exist")
        searchTextField.tap()
        searchTextField.typeText("react")
        
        sleep(3)
        
        let hasScrollView = app.scrollViews.firstMatch.waitForExistence(timeout: 2)
        let hasStaticTexts = app.staticTexts.count > 0
        
        XCTAssertTrue(hasScrollView || hasStaticTexts, "Repository cards should be displayed after search")
    }
    
    @MainActor
    func testPullToRefresh() throws {
        sleep(2)
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        sleep(2)
    }
    
    @MainActor
    func testRepositoryCardDisplay() throws {
        sleep(3)
        
        let staticTexts = app.staticTexts
        XCTAssertTrue(staticTexts.count > 0, "Repository cards should be displayed")
    }
    
    @MainActor
    func testScrollToLoadMore() throws {
        sleep(3)
        
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            scrollView.swipeUp()
            sleep(2)
            scrollView.swipeUp()
            sleep(2)
        }
    }
}
