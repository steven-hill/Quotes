//
//  SavedViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Testing
@testable import Quotes

struct SavedViewModelTests {

    @MainActor @Test("VM can fetch all quotes from the database")
    func savedViewModel_fetchAllQuotes_populatesQuotesCorrectly() throws {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
        
        try sut.fetchAllQuotes()
        
        #expect(sut.quotes.count == 1)
    }
}
