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
        let mockQuoteResult = Quote.sample
        mockQuoteService.quoteResponse = mockQuoteResult
        
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(mockQuoteService.fetchQuoteOfTheDayCallCount, 1, "Should have been called once.")
        XCTAssertEqual(quoteViewModel.state, .success(data: mockQuoteResult))
        XCTAssertFalse(quoteViewModel.hasError)
        
        guard let quote = mockQuoteResult.first else {
            XCTFail("No quote found")
            return
        }
        XCTAssertEqual(quoteViewModel.quoteContent, quote.text)
        XCTAssertEqual(quoteViewModel.quoteAuthor, quote.author)
        XCTAssertEqual(quoteViewModel.quoteToShare, "\(quote.text) - \(quote.author)")
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
        var quoteResponse: QuoteNetworkResult = []
        var shouldSucceed: Bool = true
        var fetchQuoteOfTheDayCallCount = 0
        
        func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult {
            fetchQuoteOfTheDayCallCount += 1
            if shouldSucceed {
                return quoteResponse
            } else {
                throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            }
        }
    }
}

