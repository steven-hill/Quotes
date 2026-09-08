//
//  QuoteViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/07/2024.
//

import XCTest
@testable import Quotes

@MainActor
final class QuoteViewModelTests: XCTestCase {
    
    private var quoteViewModel: QuoteViewModel!
    private var mockQuoteService: MockNetworkClient!
    
    override func setUp() async throws {
        try await super.setUp()
        mockQuoteService = MockNetworkClient()
        quoteViewModel = QuoteViewModel(quoteService: mockQuoteService)
    }
    
    override func tearDown() async throws {
        quoteViewModel = nil
        mockQuoteService = nil
        try await super.tearDown()
    }
    
    func test_Get_QuoteOfTheDay_Success() async {
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(mockQuoteService.fetchQuoteOfTheDayCallCount, 1, "Should have been called once.")
        XCTAssertEqual(quoteViewModel.state, .success)
        XCTAssertFalse(quoteViewModel.hasError)
        XCTAssertEqual(quoteViewModel.quoteContent, mockQuoteService.quote.text)
        XCTAssertEqual(quoteViewModel.quoteAuthor, mockQuoteService.quote.author)
        XCTAssertEqual(quoteViewModel.quoteToShare, "\(mockQuoteService.quote.text) - \(mockQuoteService.quote.author)")
    }
    
    func test_Get_QuoteOfTheDay_Failure() async {
        mockQuoteService.shouldSucceed = false
        
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(mockQuoteService.fetchQuoteOfTheDayCallCount, 1, "Should have been called once.")
        XCTAssertEqual(quoteViewModel.state, .failure(error: NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])))
        XCTAssertTrue(quoteViewModel.hasError)
        XCTAssertEqual(quoteViewModel.quoteAuthor, "")
        XCTAssertEqual(quoteViewModel.quoteContent, "")
        XCTAssertEqual(quoteViewModel.quoteToShare, "")
    }
    
    //MARK: - Mock Network Client
    final class MockNetworkClient: Networking {
        let quote = Quote.sample
        var shouldSucceed: Bool = true
        var fetchQuoteOfTheDayCallCount = 0
        
        func fetchQuoteOfTheDay() async throws -> Quote {
            fetchQuoteOfTheDayCallCount += 1
            if shouldSucceed {
                return quote
            } else {
                throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            }
        }
    }
}

