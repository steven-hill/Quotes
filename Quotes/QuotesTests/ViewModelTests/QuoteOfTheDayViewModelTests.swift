//
//  QuoteOfTheDayViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 08/09/2026.
//

import Testing
@testable import Quotes

@MainActor
struct QuoteOfTheDayViewModelTests {
    
    @Test("VM's properties are set correctly on init")
    func quoteOfTheDayViewModel_onInit_propertiesAreCorrect() {
        let sut = QuoteOfTheDayViewModel(quoteService: MockNetworkClient())
        
        #expect(sut.state == .idle, "Should be `.idle` on init.")
        #expect(sut.hasError == false, "Should be false on init.")
        #expect(sut.quoteContent.isEmpty, "Should be empty on init.")
        #expect(sut.quoteAuthor.isEmpty, "Should be empty on init.")
        #expect(sut.quoteToShare.isEmpty, "Should be empty on init.")
    }
    
    @Test("VM's state is correct during network request")
    func quoteOfTheDayViewModel_getQuoteOfTheDay_duringNetworkRequest_stateIsCorrect() async {
        let mockNetworkClient = MockNetworkClient()
        mockNetworkClient.shouldPauseForLoadingStateTest = true
        let sut = QuoteOfTheDayViewModel(quoteService: mockNetworkClient)
        
        let task = Task {
            await sut.getQuoteOfTheDay()
        }
        await Task.yield()
        
        #expect(sut.state == .loading, "Should be `.loading` during network request.")
        #expect(mockNetworkClient.fetchQuoteOfTheDayCallCount == 1, "Should call the method once.")
        task.cancel()
    }
    
    @Test("VM updates properties and state after successful network request")
    func quoteOfTheDayViewModel_getQuoteOfTheDay_whenSuccessful_updatesPropertiesAndState() async {
        let sut = QuoteOfTheDayViewModel(quoteService: MockNetworkClient())
        
        await sut.getQuoteOfTheDay()
        
        #expect(sut.state == .success, "Should be `.success`.")
        #expect(sut.hasError == false, "Should still be false.")
        #expect(sut.quoteContent.isEmpty == false, "Should not be empty.")
        #expect(sut.quoteAuthor.isEmpty == false, "Should not be empty.")
        #expect(sut.quoteToShare.isEmpty == false, "Should not be empty.")
    }
    
    @Test("VM handles failed network request", arguments: [
        NetworkError.networkConnectionOffline,
        NetworkError.networkConnectionLost,
        NetworkError.networkTimeout,
        NetworkError.invalidURL,
        NetworkError.invalidResponse,
        NetworkError.invalidStatusCode(statusCode: 429),
        NetworkError.invalidData(""),
        NetworkError.unknown,
    ])
    func quoteOfTheDayViewModel_getQuoteOfTheDay_whenFailed_handlesError(expectedError: NetworkError) async {
        let mockNetworkClient = MockNetworkClient()
        mockNetworkClient.shouldSucceed = false
        mockNetworkClient.error = expectedError
        let sut = QuoteOfTheDayViewModel(quoteService: mockNetworkClient)
        
        await sut.getQuoteOfTheDay()
        
        #expect(sut.state == .failure(expectedError), "Should be `.failure(NetworkError)`.")
        #expect(sut.hasError, "Should be true.")
        #expect(sut.quoteContent.isEmpty, "Should be empty on failure.")
        #expect(sut.quoteAuthor.isEmpty, "Should be empty on failure.")
        #expect(sut.quoteToShare.isEmpty, "Should be empty on failure.")
    }
    
    //MARK: - Mock Network Client
    final class MockNetworkClient: Networking {
        let quote = Quote.sample
        var shouldSucceed: Bool = true
        private var continuation: CheckedContinuation<Quote, Error>?
        var shouldPauseForLoadingStateTest = false
        var fetchQuoteOfTheDayCallCount = 0
        var error: Error?
        
        func fetchQuoteOfTheDay() async throws -> Quote {
            fetchQuoteOfTheDayCallCount += 1
            if shouldPauseForLoadingStateTest {
                return try await withCheckedThrowingContinuation { self.continuation = $0 }
            }
            if shouldSucceed {
                return quote
            } else {
                let networkError = error ?? NetworkError.unknown
                throw networkError
            }
        }
    }
}
