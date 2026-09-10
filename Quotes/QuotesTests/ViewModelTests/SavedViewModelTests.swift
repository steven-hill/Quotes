//
//  SavedViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Testing
@testable import Quotes

struct SavedViewModelTests {

    @MainActor @Test("VM can load quotes from the database")
    func savedViewModel_loadAllQuotes_populatesQuotesCorrectly() {
        let mockRepository = MockQuoteRepository()
        let sut = SavedViewModel(repository: mockRepository)
    }
}
