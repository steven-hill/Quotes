//
//  EditReflectionViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/09/2026.
//

import Testing
@testable import Quotes
import Foundation

@MainActor
struct EditReflectionViewModelTests {
    
    @Test("If quote has no `id`, VM returns early")
    func editReflectionViewModel_updateReflection_whenQuoteHasNoID_returnsEarly() {
        let mockRepository = MockQuoteRepository()
        let sut = EditReflectionViewModel(repository: mockRepository)
        
        sut.updateReflection(
            quote: Quote.sample[0],
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 0, "Should not call the method.")
    }
    
    @Test("If reflection text is empty, VM returns early, and updates confirmation dialog boolean flag")
    func editReflectionViewModel_updateReflection_whenReflectionIsEmpty_returnsEarlyAndUpdatesBoolean() {
        let mockRepository = MockQuoteRepository()
        let sut = EditReflectionViewModel(repository: mockRepository)
        
        sut.updateReflection(
            quote: makeQuote(),
            reflection: ""
        )
        
        #expect(mockRepository.updateReflectionCallCount == 0, "Should not call the method.")
        #expect(sut.showConfirmationDialog, "Should have changed to true.")
    }
    
    @Test("VM calls method on repository to update reflection, and updates boolean flag")
    func editReflectionViewModel_updateReflection_withEditedReflection_callsMethodOnRepositoryAndUpdatesBoolean() {
        let mockRepository = MockQuoteRepository()
        let sut = EditReflectionViewModel(repository: mockRepository)
        
        sut.updateReflection(
            quote: makeQuote(),
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 1, "Should call the method once.")
        #expect(sut.isReflectionUpdated, "Should have changed to true.")
    }
    
    @Test("VM handles error if update fails on the database")
    func editReflectionViewModel_updateReflection_whenUpdateFailsOnDatabase_handlesErrorCorrectly() {
        let mockRepository = MockQuoteRepository()
        mockRepository.updateSucceeded = false
        let sut = EditReflectionViewModel(repository: mockRepository)
        
        sut.updateReflection(
            quote: makeQuote(),
            reflection: "Updated reflection"
        )
        
        #expect(mockRepository.updateReflectionCallCount == 1, "Should call the method once.")
        #expect(sut.reflectionAlert == .updateError("Failed to update quote in database."), "Should be `.updateError`.")
        #expect(sut.isReflectionUpdated == false, "Should not update reflection.")
    }
    
    //MARK: - Helper method
    private func makeQuote() -> Quote {
        let persistedQuote = PersistenceHelper.makePersistedQuote(
            using: Quote.sample[0],
            reflection: "Reflection"
        )
        return PersistenceHelper.mapToQuote(persistedQuote)
    }
}
