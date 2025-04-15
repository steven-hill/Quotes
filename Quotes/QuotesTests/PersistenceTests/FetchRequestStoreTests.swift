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
    
    func test_fetchSavedQuotes_returnsEmptyArrayIfThereAreNoQuotesInTheStore() {
        sut.tryFetch()
        
        XCTAssertTrue(sut.savedQuotes.isEmpty, "`savedQuotes` should be empty.")
    }
    
    func test_fetchSavedQuotes_returnsAllSavedQuotesIfThereAreAny() throws {
        try createAndSaveTestQuote()
        
        sut.tryFetch()
        
        XCTAssertFalse(sut.savedQuotes.isEmpty, "`savedQuotes` should not be empty.")
        XCTAssertTrue(sut.savedQuotes.count == 1, "There should be one quote.")
    }
    
    func test_tryFetchSuccess_setsFetchStateCorrectly() throws {
        try createAndSaveTestQuote()
        
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
        try createAndSaveTestQuote()
        sut.tryFetch()
        XCTAssertTrue(sut.savedQuotes.count == 1, "There should be one quote.")
        
        sut.filterListByAuthorOrQuote(with: "Non existent author or quote")
        XCTAssertEqual(sut.savedQuotes.count, 0, "Search returned no results. There should be no quotes in the array.")
        
        sut.reFetchAll()
        XCTAssertTrue(sut.savedQuotes.count == 1, "The fetch request predicate should be reset and there should be one quote again.")
    }
    
    func test_controllerDidChangeContent_updatesSavedQuotesArray() throws {
        try createAndSaveTestQuote()
        try mockFetchedResultsController.performFetch()

        // Simulate Core Data notifying the delegate.
        if let controller = mockFetchedResultsController as? NSFetchedResultsController<NSFetchRequestResult> {
            sut.controllerDidChangeContent(controller)
        }
        
        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote.")
        XCTAssertEqual(sut.savedQuotes.first?.quoteContent, "Quote 1", "The first quote should have the correct content.")
    }
    
    func test_filterListByAuthorOrQuote_refetchesAllQuotesWhenSearchQueryIsEmpty() throws {
        try createAndSaveTestQuote()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "")
                
        XCTAssertTrue(sut.filteredResults.isEmpty)
        XCTAssertEqual(sut.savedQuotes.count, 1, "There should be one quote.")
    }
    
    func test_filterListByAuthorOrQuote_filtersCorrectlyWhenSearchingForQuote() throws {
        try createAndSaveTestQuote()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "Quote 1")
        
        XCTAssertEqual(sut.filteredResults.count, 1, "The filtered list should contain only one quote.")
        XCTAssertEqual(sut.filteredResults.first?.quoteContent, "Quote 1", "The filtered list should contain the correct quote.")
    }
    
    func test_filterListByAuthorOrQuote_filtersCorrectlyWhenSearchingForAuthor() throws {
        try createAndSaveTestQuote()
        sut.tryFetch()
        sut.filterListByAuthorOrQuote(with: "Author 1")
        
        XCTAssertEqual(sut.filteredResults.count, 1, "The filtered list should contain only one quote.")
        XCTAssertEqual(sut.filteredResults.first?.quoteAuthor, "Author 1", "The filtered list should contain the correct quote.")
    }
    
    func test_filterListByAuthorOrQuote_returnsEmptySavedQuotesArrayWhenThereAreNoSearchResultsFound() throws {
        try createAndSaveTestQuote()
        sut.tryFetch()
        
        sut.filterListByAuthorOrQuote(with: "Non existent author or quote")
        
        XCTAssertEqual(sut.savedQuotes.count, 0, "Search returned no results. There should be no quotes in the array.")
    }
    
    func test_deleteQuote_removesQuoteFromSavedQuotesArray() throws {
        try createAndSaveTestQuote()
        sut.tryFetch()
        XCTAssertEqual(sut.savedQuotes.count, 1)

        sut.deleteQuote(atOffsets: IndexSet(integer: 0))

        XCTAssertEqual(sut.savedQuotes.count, 0)
    }
    
    // MARK: - Helper Method
    private func createAndSaveTestQuote() throws {
        let quote1 = SavedQuote(context: mockContext)
        quote1.quoteContent = "Quote 1"
        quote1.quoteAuthor = "Author 1"
        quote1.reflection = "Reflection 1"
        
        try mockContext.save()
    }
}
