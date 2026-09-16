//
//  AppContainerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2026.
//

import Testing
@testable import Quotes

@MainActor
struct AppContainerTests {

    @Test("Initialisation succeeds and initialises dependencies")
    func appContainer_init_succeeds() throws {
        let sut = try AppContainer(isInMemoryOnly: true)
        
        #expect(sut.isRunningInDegradedMode == false, "Should be false.")
    }
    
    @Test("Integration test to check a working repository is created")
    func appContainer_quoteRepository_isCreatedAndWorks() throws {
        let sut = try AppContainer(isInMemoryOnly: true)
        let quote = Quote.sample[0]
        try sut.quoteRepository.add(quote)

        let quotes = try sut.quoteRepository.loadAllQuotes(matching: nil)

        #expect(quotes.count == 1, "Should be one.")
        #expect(sut.isRunningInDegradedMode == false, "Should be false.")
    }
}
