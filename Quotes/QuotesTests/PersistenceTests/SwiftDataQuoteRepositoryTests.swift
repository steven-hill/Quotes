//
//  SwiftDataQuoteRepositoryTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Testing
@testable import Quotes
import SwiftData
import Foundation

@MainActor
struct SwiftDataQuoteRepositoryTests {

    @Test("When database has no persisted quotes, fetch returns empty array")
    func swiftDataQuoteRepository_loadAllQuotes_whenDatabaseIsEmpty_returnsEmptyArray() throws {
        let sut = try SwiftDataQuoteRepository(container: makeContainer())
        
        let result = try sut.loadAllQuotes(matching: nil)
        
        #expect(result.isEmpty, "Should be empty.")
    }
    
    @Test("When database contains persisted quotes, fetch returns array sorted by date with latest first")
    func swiftDataQuoteRepository_loadAllQuotes_returnsAllQuotesSortedByDateDescending() throws {
        let container = try makeContainer()
        let older = PersistedQuote(
            text: "Older",
            author: "Older Author",
            date: Date(timeIntervalSince1970: 100),
            reflection: "Older Reflection"
        )
        let newer = PersistedQuote(
            text: "Newer",
            author: "Newer Author",
            date: Date(timeIntervalSince1970: 200),
            reflection: "Newer Reflection"
        )
        container.mainContext.insert(older)
        container.mainContext.insert(newer)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        let result = try sut.loadAllQuotes(matching: nil)
        
        #expect(result.count == 2, "Should have two.")
        #expect(result.map(\.text) == ["\(newer.text)", "\(older.text)"], "Should have the latest first.")
        #expect(result.map(\.author) == ["\(newer.author)", "\(older.author)"], "Should have the latest first.")
        #expect(result.map(\.reflection) == ["\(newer.reflection)", "\(older.reflection)"], "Should have the latest first.")
    }
    
    @Test("When user requests a quote is saved, it is persisted")
    func swiftDataQuoteRepository_add_persistsChange() throws {
        let container = try makeContainer()
        let sut = SwiftDataQuoteRepository(container: container)
        let quote = Quote.sample[0]
        
        try sut.add(quote)
        
        let result = try sut.loadAllQuotes(matching: nil)
        #expect(result.count == 1, "Should have one in database")
    }
    
    @Test("When a reflection is edited, the changes are persisted")
    func swiftDataQuoteRepository_updateReflection_persistsChange() throws {
        let container = try makeContainer()
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Original reflection"
        )
        container.mainContext.insert(persistedQuote)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        try sut.updateReflection(
            for: persistedQuote.id,
            reflection: "Updated reflection"
        )
        
        let result = try sut.loadAllQuotes(matching: nil)
        #expect(result.first?.reflection == "Updated reflection")
    }
    
    @Test("When a reflection is edited, but quote with id does not exist in database, correct error is thrown")
    func swiftDataQuoteRepository_updateReflection_whenQuoteDoesNotExistInDatabase_throwsCorrectError() throws {
        let container = try makeContainer()
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Original reflection"
        )
        let sut = SwiftDataQuoteRepository(container: container)
        
        #expect(performing: {
                try sut.updateReflection(
                    for: persistedQuote.id,
                    reflection: "Updated reflection"
                )
            }, throws: { (error: any Error) -> Bool in
                guard let repoError = error as? RepositoryError else { return false }
                return repoError == .quoteNotFound
            })
        #expect(persistedQuote.reflection == "Original reflection")
    }
    
    @Test("When a quote is deleted, the change is persisted")
    func swiftDataQuoteRepository_delete_persistsChange() throws {
        let container = try makeContainer()
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        container.mainContext.insert(persistedQuote)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        try sut.delete(persistedQuote.id)
        
        let result = try sut.loadAllQuotes(matching: nil)
        #expect(result.isEmpty, "Should be empty.")
    }
    
    @Test("When a persisted quote is to be deleted, but quote with id does not exist in database, correct error is thrown")
    func swiftDataQuoteRepository_delete_whenQuoteDoesNotExistInDatabase_throwsCorrectError() throws {
        let container = try makeContainer()
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        let sut = SwiftDataQuoteRepository(container: container)
        
        #expect(performing: {
            try sut.delete(persistedQuote.id)
        }, throws: { (error: any Error) -> Bool in
            guard let repoError = error as? RepositoryError else { return false }
            return repoError == .quoteNotFound
        })
    }
    
    @Test("When search query returns no results, no quotes are returned")
    func swiftDataQuoteRepository_loadAllQuotes_whenSearchReturnsNoResults_returnsEmptyArray() throws {
        let container = try makeContainer()
        let quoteA = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "A"
        )
        container.mainContext.insert(quoteA)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        let result = try sut.loadAllQuotes(matching: "Not found")
        
        #expect(result.isEmpty, "Should be empty.")
    }
    
    @Test("When search query returns results for text or author, filtered quotes are returned")
    func swiftDataQuoteRepository_loadAllQuotes_whenSearchReturnsResults_returnsFilteredResults() throws {
        let container = try makeContainer()
        let quoteA = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "A"
        )
        let quoteB = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[1],
            reflection: "B"
        )
        container.mainContext.insert(quoteA)
        container.mainContext.insert(quoteB)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        let textResult = try sut.loadAllQuotes(matching: "first")
        #expect(textResult.count == 1, "Should have one.")
        
        let authorResult = try sut.loadAllQuotes(matching: "Writer")
        #expect(authorResult.count == 1, "Should have one.")
        
        let result = try sut.loadAllQuotes(matching: "text")
        #expect(result.count == 2, "Should have two.")
    }
    
    //MARK: - Helper
    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: PersistedQuote.self,
            configurations: configuration
        )
    }
}
