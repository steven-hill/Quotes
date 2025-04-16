//
//  FetchRequestStoreTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2024.
//

import XCTest
@testable import Quotes
import CoreData

final class FetchRequestStoreTests: XCTestCase {
    
    private var sut: FetchRequestStore!
    private var mockContext: NSManagedObjectContext!
    private var mockFetchedResultsController: NSFetchedResultsController<SavedQuote>!
    
    override func setUp() {
        super.setUp()
        let persistentContainer = NSPersistentContainer(name: "Quotes")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        mockContext = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<SavedQuote> = SavedQuote.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SavedQuote.quoteAuthor, ascending: true)]
        
        mockFetchedResultsController = NSFetchedResultsController<SavedQuote>(
            fetchRequest: fetchRequest,
            managedObjectContext: mockContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        sut = FetchRequestStore(savedQuotesController: mockFetchedResultsController, context: mockContext)
    }
    
    override func tearDown() {
        sut = nil
        mockContext = nil
        mockFetchedResultsController = nil
        super.tearDown()
    }
    
    func test_fetchSavedQuotes_returnsEmptyArray_ifThereAreNoQuotesInTheStore() {
        sut.tryFetch()
        
        XCTAssertTrue(sut.savedQuotes.isEmpty, "`savedQuotes` should be empty.")
    }
    
    func test_fetchSavedQuotes_returnsAllSavedQuotes_ifThereAreAny() throws {
        try createAndSaveOneTestQuote()
        
        sut.tryFetch()
        
        XCTAssertFalse(sut.savedQuotes.isEmpty, "`savedQuotes` should not be empty.")
        XCTAssertTrue(sut.savedQuotes.count == 1, "There should be one quote.")
    }
    
    func test_tryFetchSuccess_setsFetchStateCorrectly() throws {
        try createAndSaveOneTestQuote()
        
        sut.tryFetch()
        
        XCTAssertEqual(sut.fetchState, .success(data: sut.savedQuotes), "`FetchState` should be .success.")
    }
    
    func test_tryFetchFailure_setsFetchStateCorrectly() {
        sut.fetchRequestHasError = true
        let error = NSError(domain: "", code: 0, userInfo: nil)
        
        sut.fetchState = .failure(error: error)
        
        XCTAssertEqual(sut.fetchState, .failure(error: error), "`FetchState` should be .failure.")
    }
    
    func test_reFetchAll_resetsFetchRequestPredicateToOriginalAndFetchesAllQuotes() throws {
        try createAndSaveMultipleTestQuotes()
        sut.tryFetch()
        XCTAssertTrue(sut.savedQuotes.count == 2, "There should be two quotes.")
        
        sut.filterListByAuthorOrQuote(with: "Non existent author or quote")
        XCTAssertEqual(sut.savedQuotes.count, 0, "Search returned no results. There should be no quotes in the array.")
        
        sut.reFetchAll()
        XCTAssertTrue(sut.savedQuotes.count == 2, "The fetch request predicate should be reset and there should be two quotes again.")
    }
    
    func test_controllerDidChangeContent_updatesSavedQuotesArray() throws {
        try createAndSaveOneTestQuote()
        try mockFetchedResultsController.performFetch()

        // Simulate Core Data notifying the delegate.
        if let controller = mockFetchedResultsController as? NSFetchedResultsController<NSFetchRequestResult> {
            sut.controllerDidChangeContent(controller)
        }
        
        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote.")
        XCTAssertEqual(sut.savedQuotes.first?.quoteContent, "Quote 1", "The quote should have the correct content.")
    }
    
    func test_filterListByAuthorOrQuote_refetchesAllQuotes_whenSearchQueryIsEmpty() throws {
        try createAndSaveOneTestQuote()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "")
                
        XCTAssertTrue(sut.filteredResults.isEmpty, "The filtered array should be empty.")
        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote.")
    }
    
    func test_filterListByAuthorOrQuote_filtersCorrectly_whenSearchingForQuote() throws {
        try createAndSaveMultipleTestQuotes()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "Quote 3")
        
        XCTAssertEqual(sut.filteredResults.count, 1, "The filtered array should contain only one quote.")
        XCTAssertEqual(sut.filteredResults.first?.quoteContent, "Quote 3", "The filtered array should contain the correct quote.")
    }
    
    func test_filterListByAuthorOrQuote_filtersCorrectly_whenSearchingForAuthor() throws {
        try createAndSaveMultipleTestQuotes()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "Author 2")
        
        XCTAssertEqual(sut.savedQuotes.count, 1, "The saved quotes array should contain only one quote.")
        XCTAssertEqual(sut.savedQuotes.first?.quoteAuthor, "Author 2", "The saved quotes array should contain the correct quote.")
    }
    
    func test_filterListByAuthorOrQuote_returnsEmptySavedQuotesArray_whenThereAreNoSearchResultsFound() throws {
        try createAndSaveOneTestQuote()
        sut.tryFetch()
        
        sut.filterListByAuthorOrQuote(with: "Non existent author or quote")
        
        XCTAssertEqual(sut.savedQuotes.count, 0, "Search returned no results. There should be no quotes in the array.")
    }
    
    func test_deleteQuote_removesQuoteFromSavedQuotesArray() throws {
        try createAndSaveMultipleTestQuotes()
        sut.tryFetch()
        XCTAssertEqual(sut.savedQuotes.count, 2, "There should be two quotes in the array.")

        sut.deleteQuote(atOffsets: IndexSet(integer: 0))

        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote in the array.")
        XCTAssertEqual(sut.savedQuotes.first?.quoteContent, "Quote 3", "The quote that was not deleted should still be in the array.")
    }
    
    func test_fetchFilteredResults_updatesFilteredResultsAndState_whenAResultIsFound() throws {
        try createAndSaveMultipleTestQuotes()
        
        sut.filterListByAuthorOrQuote(with: "Author 2")

        XCTAssertEqual(sut.filteredResults.count, 1, "There should be one quote in the array.")
        XCTAssertEqual(sut.filteredResults.first?.quoteAuthor, "Author 2", "The filtered result should match the search query.")

        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote in the array.")
        XCTAssertEqual(sut.savedQuotes.first?.quoteAuthor, "Author 2", "The saved quote should match the search query.")

        if case .success(let data) = sut.fetchState {
            XCTAssertEqual(data.count, 1, "The fetched data should contain one result.")
            XCTAssertEqual(data.first?.quoteAuthor, "Author 2", "The fetched data should match the search query.")
        } else {
            XCTFail("Expected .success fetchState")
        }
    }
    
    func test_fetchFilteredResults_withNoMatches_setsEmptyResultsAndSuccessState() throws {
        try createAndSaveMultipleTestQuotes()

        sut.filterListByAuthorOrQuote(with: "Author 0")

        XCTAssertTrue(sut.filteredResults.isEmpty, "The filtered results array should contain no quotes.")
        XCTAssertTrue(sut.savedQuotes.isEmpty, "The saved quotes array should contain no quotes.")

        if case .success(let data) = sut.fetchState {
            XCTAssertTrue(data.isEmpty, "The fetched data should contain no quotes.")
        } else {
            XCTFail("Expected .success even when result is empty")
        }
    }

    // MARK: - Helper Methods
    private func createAndSaveOneTestQuote() throws {
        let quote1 = SavedQuote(context: mockContext)
        quote1.quoteContent = "Quote 1"
        quote1.quoteAuthor = "Author 1"
        quote1.reflection = "Reflection 1"
        
        try mockContext.save()
    }
    
    private func createAndSaveMultipleTestQuotes() throws {
        let quote2 = SavedQuote(context: mockContext)
        quote2.quoteContent = "Quote 2"
        quote2.quoteAuthor = "Author 2"
        quote2.reflection = "Reflection 2"
        
        let quote3 = SavedQuote(context: mockContext)
        quote3.quoteContent = "Quote 3"
        quote3.quoteAuthor = "Author 3"
        quote3.reflection = "Reflection 3"
        
        try mockContext.save()
    }
}
