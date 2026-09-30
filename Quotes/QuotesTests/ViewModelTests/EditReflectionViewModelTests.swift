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
    
    @Test("If reflection text is empty, VM returns early, and updates confirmation dialog boolean flag")
    func editReflectionViewModel_updateReflection_whenReflectionIsEmpty_returnsEarlyAndUpdatesBoolean() {
        let mockRepository = MockQuoteRepository()
        let sut = EditReflectionViewModel(repository: mockRepository)
        
        sut.updateReflection(
            quoteID: Quote.sample[0].id ?? UUID(),
            reflection: ""
        )
        
        #expect(mockRepository.updateReflectionCallCount == 0, "Should not call the method.")
        #expect(sut.showConfirmationDialog, "Should have changed to true.")
    }
}
