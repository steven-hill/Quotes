//
//  QuoteOfTheDayViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 08/09/2026.
//

import Testing
@testable import Quotes

struct QuoteOfTheDayViewModelTests {
    
    @MainActor @Test("VM's properties are set correctly on init")
    func quoteOfTheDayViewModel_onInit_propertiesAreCorrect() {
        let sut = QuoteOfTheDayViewModel(quoteService: MockNetworkClient())
        
        #expect(sut.state == .idle, "Should be `.idle` on init.")
        #expect(sut.hasError == false, "Should be false on init.")
        #expect(sut.quoteContent.isEmpty, "Should be empty on init.")
        #expect(sut.quoteAuthor.isEmpty, "Should be empty on init.")
        #expect(sut.quoteToShare.isEmpty, "Should be empty on init.")
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
                throw NetworkError.unknown
            }
        }
    }
}
