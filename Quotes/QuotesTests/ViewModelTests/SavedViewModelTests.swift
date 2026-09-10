//
//  SavedViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Testing
@testable import Quotes

struct SavedViewModelTests {
    
    @MainActor @Test("VM receives no quotes if none have been saved yet")
    func savedViewModel_fetchAllQuotes_whenDatabaseIsEmpty_populatesQuotesCorrectly() throws {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        try sut.fetchAllQuotes()
        
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }

    @MainActor @Test("VM can fetch all quotes from the database if they exist")
    func savedViewModel_fetchAllQuotes_whenQuotesExistInDatabase_populatesQuotesCorrectly() throws {
        let mockRepository = MockQuoteRepository()
        mockRepository.stubbedQuotes = [Quote.sample]
        let sut = SavedViewModel(repository: mockRepository)
        
        try sut.fetchAllQuotes()
        
        #expect(sut.quotes.count == 1, "Should load 1 quote from the database.")
    }
    
    @MainActor @Test("VM handles error if database fails to fetch all quotes from the database")
    func savedViewModel_fetchAllQuotes_whenFetchFromDatabaseFails_handlesErrorCorrectly() throws {
        let mockRepository = MockQuoteRepository()
        mockRepository.stubbedQuotes = [Quote.sample]
        mockRepository.fetchSucceeded = false
        let sut = SavedViewModel(repository: mockRepository)
        
        try sut.fetchAllQuotes()
        
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }
}
