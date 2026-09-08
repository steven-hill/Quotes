//
//  QuoteOfTheDayViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 08/09/2026.
//

import Testing
@testable import Quotes

struct QuoteOfTheDayViewModelTests {
    
    @MainActor @Test("VM state is set correctly on init")
    func quoteOfTheDayViewModel_onInit_stateIsCorrect() {
        let sut = QuoteOfTheDayViewModel(quoteService: MockNetworkClient())
        
        #expect(sut.state == .idle, "Should be `.idle` on init.")
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
