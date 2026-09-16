//
//  AppContainerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2026.
//

import Testing
@testable import Quotes
import SwiftData

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
    
    @Test("When persistent store fails, falls back to in-memory storage")
    func appContainer_whenPersistentStoreFails_triesToCreateInMemoryModelContainer() throws {
        let factory = MockModelContainerFactory()
        factory.failureCount = 1
        
        let sut = try AppContainer(isInMemoryOnly: true, modelContainerFactory: factory)
        
        #expect(sut.isRunningInDegradedMode, "Should be true.")
        #expect(factory.callCount == 2, "Should have tried to make a model container twice.")
    }
    
    @Test("When both persistent and in-memory stores fail, throws correct error")
    func appContainer_whenLocalStorageTotallyFails_throwsCorrectError() {
        let factory = MockModelContainerFactory()
        factory.failureCount = 2

        #expect(throws: AppContainerError.self, "Should be of type `AppContainerError`") {
            try AppContainer(isInMemoryOnly: true, modelContainerFactory: factory)
        }
        #expect(factory.callCount == 2, "Should have tried to make a model container twice.")
    }
    
    //MARK: - Mock Model Container Factory
    final class MockModelContainerFactory: ModelContainerCreating {
        var failureCount = 0
        private(set) var callCount = 0
        
        func makeContainer(
            schema: Schema,
            configuration: ModelConfiguration
        ) throws -> ModelContainer {
            callCount += 1
            if callCount <= failureCount {
                throw SwiftDataError.loadIssueModelContainer
                    }
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        }
    }
}
