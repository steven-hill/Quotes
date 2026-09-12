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
        let (sut, _) = makeSUTAndTwoPersistedQuotesInRepository()
        
        sut.fetchAllQuotes()
        
        #expect(sut.quotes.count == 2, "Should load 2 quotes from the database.")
    }
    
    @Test("VM handles error if database fails to fetch all quotes from the database")
    func savedViewModel_fetchAllQuotes_whenFetchFromDatabaseFails_handlesErrorCorrectly() {
        let mockRepository = MockQuoteRepository()
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        mockRepository.persistedQuotes = [persistedQuote]
        mockRepository.fetchSucceeded = false
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.fetchAllQuotes()
        
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }
    
    @Test("VM handles search queries (that match or don't), and quotes is updated correctly")
    func savedViewModel_fetchAllQuotes_whenSearching_populatesQuotesCorrectly() async throws {
        let (sut, _) = makeSUTAndTwoPersistedQuotesInRepository()
        
        sut.searchText = "First"
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(sut.quotes.count == 1, "Should have one.")
        
        sut.searchText = "No matches"
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(sut.quotes.isEmpty, "Should be empty.")
    }
    
    @Test("VM cleans up text that contains spaces, tabs and new lines before searching")
    func savedViewModel_setupSearch_cleansUpRawText() async throws {
        let (sut, _) = makeSUTAndTwoPersistedQuotesInRepository()
        
        sut.searchText = " First  "
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(sut.quotes.count == 1, "Should have one.")
        
        sut.searchText = "  First   "
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(sut.quotes.count == 1, "Should have one.")
        
        sut.searchText = "\n   First   \n"
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(sut.quotes.count == 1, "Should have one.")
    }
    
    @Test("When identical search terms are typed sequentially, the duplicate request is removed")
    func savedViewModel_setupSearch_sequentialDuplicateSearch_callsRepositoryOnlyOnce() async throws {
        let (sut, mockRepository) = makeSUTAndTwoPersistedQuotesInRepository()
        
        sut.searchText = "First"
        try await Task.sleep(for: .milliseconds(400))
        
        sut.searchText = "First "
        try await Task.sleep(for: .milliseconds(100))
        
        sut.searchText = "First"
        try await Task.sleep(for: .milliseconds(400))
        
        #expect(mockRepository.loadAllQuotesCallCount == 1, "Repository should only be queried once for duplicate values.")
        #expect(sut.quotes.count == 1, "Should have one quote after filtering.")
    }
    
    @Test("VM can add a quote to the database, and refreshes the quotes list")
    func savedViewModel_add_callsMethodsOnRepository() {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.add(quote: Quote.sample[0])
        
        #expect(mockRepository.addCallCount == 1, "Should call the method once.")
        #expect(mockRepository.loadAllQuotesCallCount == 1, "Should call the method once.")
    }
    
    @Test("Updating a quote without an id, returns early and updates error properties")
    func savedViewModel_update_whenQuoteIdIsNil_resultsInError() {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.update(
            quote: Quote.sample[0],
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 0, "Should not be called.")
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
    }
    
    @Test("VM calls methods on repository to update a quote if that quote has an id, and refetch quotes")
    func savedViewModel_update_callsMethodsOnRepository() {
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Original reflection"
        )
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.update(
            quote: mapToQuote(persistedQuote),
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 1, "Should call the method once.")
        #expect(mockRepository.loadAllQuotesCallCount == 1, "Should call the method once.")
    }
    
    @Test("Deleting a quote without an id, returns early and updates error properties")
    func savedViewModel_delete_whenQuoteIdIsNil_resultsInError() {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.delete(quote: Quote.sample[0])
        
        #expect(mockRepository.deleteCallCount == 0, "Should not be called.")
        #expect(sut.hasError, "Should be true.")
        #expect(sut.errorMessage != nil, "Should not be nil.")
    }
    
    @Test("VM calls methods on repository to delete a quote if that quote has an id, and reload quotes")
    func savedViewModel_delete_callsMethodsOnRepository() {
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        let quote = mapToQuote(persistedQuote)
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        sut.delete(quote: quote)
        
        #expect(mockRepository.deleteCallCount == 1, "Should call the method once.")
        #expect(mockRepository.loadAllQuotesCallCount == 1, "Should call the method once.")
    }
    
    //MARK: - SUT Helper
    private func makeSUTAndTwoPersistedQuotesInRepository() -> (
        sut: SavedViewModel,
        mockRepository: MockQuoteRepository
    ) {
        let mockRepository = MockQuoteRepository()
        let firstPersistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        let secondPersistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[1],
            reflection: "Reflection"
        )
        mockRepository.persistedQuotes = [firstPersistedQuote, secondPersistedQuote]
        let sut = SavedViewModel(repository: mockRepository)
        return (sut, mockRepository)
    }
    
    //MARK: - Mapper
    private func mapToQuote(_ persistedQuote: PersistedQuote) -> Quote {
        Quote(
            id: persistedQuote.id,
            text: persistedQuote.text,
            author: persistedQuote.author,
            date: persistedQuote.date,
            reflection: persistedQuote.reflection
        )
    }
}
