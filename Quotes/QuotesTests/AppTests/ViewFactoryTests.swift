//
//  ViewFactoryTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 18/09/2026.
//

import Testing
@testable import Quotes

struct ViewFactoryTests {

    @Test("View factory successfully accesses network client for QuoteOfTheDayView")
    func viewFactory_makeQuoteOfTheDayView_pullsCorrectDependencyFromAppContainer() {
        let sut = ViewFactory()
    }
}
