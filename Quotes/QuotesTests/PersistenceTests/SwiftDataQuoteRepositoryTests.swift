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
        
        let result = try sut.loadAllQuotes()
        
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
        
        let result = try sut.loadAllQuotes()
        
        #expect(result.count == 2, "Should have two.")
        #expect(result.map(\.text) == ["\(newer.text)", "\(older.text)"], "Should have the latest first.")
        #expect(result.map(\.author) == ["\(newer.author)", "\(older.author)"], "Should have the latest first.")
        #expect(result.map(\.reflection) == ["\(newer.reflection)", "\(older.reflection)"], "Should have the latest first.")
    }
    
    @Test("When a reflection is edited, the changes are persisted")
    func swiftDataQuoteRepository_updateReflection_persistsChange() throws {
        let container = try makeContainer()
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Quote.sample.date,
            reflection: "Original reflection"
        )
        container.mainContext.insert(persistedQuote)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        try sut.updateReflection(
            for: persistedQuote.id,
            reflection: "Updated reflection"
        )
        
        let result = try sut.loadAllQuotes()        
        #expect(result.first?.reflection == "Updated reflection")
    }
    
    @Test("When a reflection is edited, but quote with id does not exist in database, correct error is thrown")
    func swiftDataQuoteRepository_updateReflection_whenQuoteDoesNotExistInDatabase_throwsCorrectError() throws {
        let container = try makeContainer()
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Quote.sample.date,
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
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Quote.sample.date,
            reflection: "Reflection"
        )
        container.mainContext.insert(persistedQuote)
        try container.mainContext.save()
        let sut = SwiftDataQuoteRepository(container: container)
        
        try sut.delete(persistedQuote.id)
        
        let result = try sut.loadAllQuotes()
        #expect(result.isEmpty, "Should be empty.")
    }
    
    @Test("When a persisted quote is to be deleted, but quote with id does not exist in database, correct error is thrown")
    func swiftDataQuoteRepository_delete_whenQuoteDoesNotExistInDatabase_throwsCorrectError() throws {
        let container = try makeContainer()
        let persistedQuote = PersistedQuote(
            text: Quote.sample.text,
            author: Quote.sample.author,
            date: Quote.sample.date,
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
