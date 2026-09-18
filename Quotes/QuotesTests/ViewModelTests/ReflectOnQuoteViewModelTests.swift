//
//  ReflectOnQuoteViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 18/09/2026.
//

import Testing
@testable import Quotes

@MainActor
struct ReflectOnQuoteViewModelTests {

    @Test("VM's properties are set correctly on init")
    func reflectOnQuoteViewModel_onInit_propertiesAreSetCorrectly() {
        let sut = ReflectOnQuoteViewModel(repository: MockQuoteRepository())
        
        #expect(sut.isQuoteSaved == false, "Should be false.")
        #expect(sut.hasError == false, "Should be false.")
        #expect(sut.errorMessage.isEmpty, "Should be empty.")
        #expect(sut.showConfirmationDialog == false, "Should be false.")
    }
    
    @Test("VM calls method on repository to save a quote with reflection, and updates boolean flag")
    func reflectOnQuoteViewModel_saveQuoteWithReflection_whenUserHasAddedAReflection_callsMethodOnRepositoryAndUpdatesBoolean() {
        let mockRepository = MockQuoteRepository()
        let sut = ReflectOnQuoteViewModel(repository: mockRepository)
        
        sut.saveQuoteWithReflection(
            quote: Quote.sample[0],
            reflection: "Reflection"
        )
        
        #expect(mockRepository.addCallCount == 1, "Should call the method once.")
        #expect(sut.isQuoteSaved, "Should have changed to true.")
    }
    
    @Test("If reflection text is empty, VM returns early, and updates boolean flag")
    func reflectOnQuoteViewModel_saveQuoteWithReflection_whenReflectionIsEmpty_returnsEarlyAndUpdatesBoolean() {
        let mockRepository = MockQuoteRepository()
        let sut = ReflectOnQuoteViewModel(repository: mockRepository)
        
        sut.saveQuoteWithReflection(
            quote: Quote.sample[0],
            reflection: ""
        )
        
        #expect(mockRepository.addCallCount == 0, "Should not call the method.")
        #expect(sut.showConfirmationDialog, "Should have changed to true.")
    }
}
