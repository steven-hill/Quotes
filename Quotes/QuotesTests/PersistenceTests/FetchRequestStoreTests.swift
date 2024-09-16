//
//  FetchRequestStoreTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2024.
//

import XCTest
@testable import Quotes

final class FetchRequestStoreTests: XCTestCase {

    var sut: MockFetchRequestStore!
    
    override func setUp() {
        sut = MockFetchRequestStore()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_tryFetchSuccess_returnsFetchStateSuccess() {
        sut.tryFetch()
        
        XCTAssertEqual(sut.fetchState, .success(data: sut.savedQuotes), "Successful fetch should return FetchState success case.")
        XCTAssertEqual(sut.fetchRequestHasError, false, "'fetchRequestHasError' should remain false in success case.")
    }
    
    func test_tryFetchFailure_returnsFetchStateFailure() {
        sut.fetchSuccessful = false
        
        sut.tryFetch()
        
        XCTAssertEqual(sut.fetchState, .failure(error: MockFetchRequestStore.MockFetchError.fetchFailure), "Fetch failure should return FetchState failure case.")
        XCTAssertEqual(sut.fetchRequestHasError, true, "'fetchRequestHasError' should be true in failure case.")
    }
    
    func test_tryFetch_returnsEmptyArrayWhenStoreIsEmpty() {
        sut.tryFetch()
        
        XCTAssertTrue(sut.savedQuotes.isEmpty, "Array should be empty if there are no fetched objects.")
    }
    
    func test_tryFetch_returnsOneQuoteWhenStoreHasOneObject() {
        let test = createMockFetchedQuote(quoteContent: "Test content", quoteAuthor: "Test author", reflection: "Test reflection")
        
        sut.tryFetch()
        sut.savedQuotes.append(test)
        
        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one saved quote in the fetched objects.")
    }
    
    func test_tryFetch_returnsMultipleQuotesWhenStoreHasMultipleObjects() {
        let test1 = createMockFetchedQuote(quoteContent: "Test content", quoteAuthor: "Test author", reflection: "Test reflection")
        let test2 = createMockFetchedQuote(quoteContent: "Test content", quoteAuthor: "Test author", reflection: "Test reflection")
        let test3 = createMockFetchedQuote(quoteContent: "Test content", quoteAuthor: "Test author", reflection: "Test reflection")
        
        sut.tryFetch()
        sut.savedQuotes.append(test1)
        sut.savedQuotes.append(test2)
        sut.savedQuotes.append(test3)
        
        XCTAssertEqual(sut.savedQuotes.count, 3, "There should be three saved quotes in the fetched objects.")
    }

    // MARK: - Helper Method

    private func createMockFetchedQuote(quoteContent: String, quoteAuthor: String, reflection: String) -> MockFetchRequestStore.MockedSavedQuote {
        let quote = MockFetchRequestStore.MockedSavedQuote(quoteContent: quoteContent, quoteAuthor: quoteAuthor, reflection: reflection)
        return quote
    }
}
