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
        let sut = ReflectOnQuoteViewModel()
        
        #expect(sut.isQuoteSaved == false, "Should be false.")
        #expect(sut.hasError == false, "Should be false.")
        #expect(sut.errorMessage.isEmpty, "Should be empty.")
        #expect(sut.showConfirmationDialog == false, "Should be false.")
    }
}
