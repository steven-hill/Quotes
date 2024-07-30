//
//  QuoteViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/07/2024.
//

import XCTest
@testable import Quotes

final class QuoteViewModelTests: XCTestCase {
    
    var quoteViewModel: QuoteViewModel!
    var mockQuoteService: MockQuoteService!
    
    override func setUp() {
        super.setUp()
        mockQuoteService = MockQuoteService()
        quoteViewModel = QuoteViewModel(quoteService: mockQuoteService)
    }
    
    override func tearDown() {
        quoteViewModel = nil
        mockQuoteService = nil
        super.tearDown()
    }
    
    func test_Get_QuoteOfTheDay_Success() async {
        let mockQuote = QuoteServiceResultElement(q: "When you want to be honored by others, you learn to honor them first.", a: "Sathya Sai Baba", h: "<blockquote>&ldquo;When you want to be honored by others, you learn to honor them first.&rdquo; &mdash; <footer>Sathya Sai Baba</footer></blockquote>")
        mockQuoteService.quoteResponse = [mockQuote]
        
        await quoteViewModel.getQuoteOfTheDay()
        
        XCTAssertEqual(quoteViewModel.state, .success(data: [mockQuote]))
        XCTAssertFalse(quoteViewModel.hasError)
        XCTAssertEqual(quoteViewModel.quoteContent, mockQuote.quote)
        XCTAssertEqual(quoteViewModel.quoteAuthor, mockQuote.author)
        XCTAssertEqual(quoteViewModel.quoteToShare, "\(mockQuote.quote) - \(mockQuote.author)")
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
