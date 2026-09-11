//
//  SavedViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Testing
@testable import Quotes
import Foundation

@MainActor
struct SavedViewModelTests {
    
    @Test("VM receives no quotes if none have been saved yet")
    func savedViewModel_fetchAllQuotes_whenDatabaseIsEmpty_populatesQuotesCorrectly() {
        let sut = SavedViewModel(repository: MockQuoteRepository())
        
        sut.fetchAllQuotes()
        
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }

    @Test("VM can fetch all quotes from the database if they exist")
    func savedViewModel_fetchAllQuotes_whenQuotesExistInDatabase_populatesQuotesCorrectly() {
        let mockRepository = MockQuoteRepository()
        mockRepository.stubbedQuotes = [Quote.sample]
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.fetchAllQuotes()
        
        #expect(sut.quotes.count == 1, "Should load 1 quote from the database.")
    }
    
    @Test("VM handles error if database fails to fetch all quotes from the database")
    func savedViewModel_fetchAllQuotes_whenFetchFromDatabaseFails_handlesErrorCorrectly() {
        let mockRepository = MockQuoteRepository()
        mockRepository.stubbedQuotes = [Quote.sample]
        mockRepository.fetchSucceeded = false
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.fetchAllQuotes()
        
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }
    
    @Test("VM can add a quote to the database")
    func savedViewModel_add_callsMethodOnRepository() {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.add(quote: Quote.sample)
        
        #expect(mockRepository.addCallCount == 1, "Should call the method once.")
    }
    
    @Test("Updating a quote without an id, returns early and updates error properties")
    func savedViewModel_update_whenQuoteIdIsNil_resultsInError() {
        let quote = Quote.sample
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.update(
            quote: quote,
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 0, "Should not be called.")
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
    }
    
    @Test("VM calls method on repository to update a quote if that quote has an id")
    func savedViewModel_update_callsMethodOnRepository() {
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Date(),
            reflection: "Original reflection"
        )
        let quote = Quote(
            id: persistedQuote.id,
            text: persistedQuote.text,
            author: persistedQuote.author,
            date: persistedQuote.date,
            reflection: persistedQuote.reflection
        )
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.update(
            quote: quote,
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 1, "Should call the method once.")
    }
    
    @Test("Deleting a quote without an id, returns early and updates error properties")
    func savedViewModel_delete_whenQuoteIdIsNil_resultsInError() {
        let quote = Quote.sample
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.delete(quote: quote)
        
        #expect(mockRepository.deleteCallCount == 0, "Should not be called.")
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
    }
    
    @Test("VM calls method on repository to delete a quote if that quote has an id")
    func savedViewModel_delete_callsMethodOnRepository() {
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Date(),
            reflection: "Reflection"
        )
        let quote = Quote(
            id: persistedQuote.id,
            text: persistedQuote.text,
            author: persistedQuote.author,
            date: persistedQuote.date,
            reflection: persistedQuote.reflection
        )
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.delete(quote: quote)
        
        #expect(mockRepository.deleteCallCount == 1, "Should call the method once.")
    }
}
