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
        let mockQuote = Quote(text: "When you want to be honored by others, you learn to honor them first.", author: "Sathya Sai Baba")
        mockQuoteService.quoteResponse = [mockQuote]
        
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(quoteViewModel.state, .success(data: [mockQuote]))
        XCTAssertFalse(quoteViewModel.hasError)
        XCTAssertEqual(quoteViewModel.quoteContent, mockQuote.text)
        XCTAssertEqual(quoteViewModel.quoteAuthor, mockQuote.author)
        XCTAssertEqual(quoteViewModel.quoteToShare, "\(mockQuote.text) - \(mockQuote.author)")
    }
    
    func test_Get_QuoteOfTheDay_Failure() async {
        mockQuoteService.shouldSucceed = false
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(quoteViewModel.state, .failure(error: NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])))
        XCTAssertTrue(quoteViewModel.hasError)
        XCTAssertEqual(quoteViewModel.quoteAuthor, "")
        XCTAssertEqual(quoteViewModel.quoteContent, "")
        XCTAssertEqual(quoteViewModel.quoteToShare, "")
    }
}
