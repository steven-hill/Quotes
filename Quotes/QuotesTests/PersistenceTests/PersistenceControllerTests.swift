//
//  PersistenceControllerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 31/07/2024.
//

import XCTest
@testable import Quotes
import CoreData

final class PersistenceControllerTests: XCTestCase {
    
    var sut: PersistenceController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = PersistenceController(inMemory: true)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_Initialization() {
        XCTAssertNotNil(sut.container)
        XCTAssertFalse(sut.hasError)
        XCTAssertEqual(sut.persistenceError, .none)
    }
    
    func test_PreviewPersistenceController_Has_15SavedQuotes() {
        let previewController = PersistenceController.preview
        let fetchRequest: NSFetchRequest<SavedQuote> = SavedQuote.fetchRequest()
        let results = try? previewController.container.viewContext.fetch(fetchRequest)
        
        XCTAssertEqual(results?.count, 15, "There should be 15 saved quotes.")
    }
    
    func test_SavedQuotesFetchRequestSortDescriptorCount_EqualsOne() {
        let fetchRequest = sut.savedQuotesFetchRequest.sortDescriptors?.count
        XCTAssertEqual(fetchRequest, 1, "There should only be one sort descriptor.")
    }
    
    func test_SavedQuotesFetchRequest_IsValid() {
        let fetchRequest = sut.savedQuotesFetchRequest
        XCTAssertEqual(fetchRequest.sortDescriptors?.first?.key, "quoteAuthor", "Saved quotes should be sorted by quote author.")
        XCTAssertTrue(fetchRequest.sortDescriptors?.first?.ascending ?? false, "Saved quotes should be sorted alphabetically.")
    }
    
    func test_SaveSuccess() {
        _ = createTestQuote()
        
        XCTAssertNoThrow(try sut.save())
        XCTAssertFalse(sut.hasError)
        XCTAssertEqual(sut.persistenceError, .none)
        
        let results = fetchAllQuotes(from: sut)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.quoteAuthor, "Test author", "Should be 'Test author'.")
        XCTAssertEqual(results.first?.quoteContent, "Test quote", "Should be 'Test quote'.")
        XCTAssertEqual(results.first?.reflection, "Test reflection", "Should be 'Test reflection'.")
    }
    
    func test_DeleteQuote() throws {
        let newQuote = createTestQuote()
        try sut.save()
        
        XCTAssertNoThrow(try sut.delete(savedQuote: newQuote))
        
        let results = fetchAllQuotes(from: sut)
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestQuote() -> SavedQuote {
        let context = sut.container.viewContext
        let newQuote = SavedQuote(context: context)
        newQuote.quoteContent = "Test quote"
        newQuote.quoteAuthor = "Test author"
        newQuote.reflection = "Test reflection"
        return newQuote
    }
    
    private func fetchAllQuotes(from controller: PersistenceController) -> [SavedQuote] {
        let fetchRequest: NSFetchRequest<SavedQuote> = SavedQuote.fetchRequest()
        return (try? controller.container.viewContext.fetch(fetchRequest)) ?? []
    }
}
