//
//  ViewFactoryTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 18/09/2026.
//

import Testing
@testable import Quotes

@MainActor
struct ViewFactoryTests {

    @Test("View factory successfully accesses network client for QuoteOfTheDayView")
    func viewFactory_makeQuoteOfTheDayView_pullsCorrectDependencyFromAppContainer() {
        let mockDependencyContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockDependencyContainer)
    }
}

final class MockDependencyContainer: AppDependencyContaining {
    let quoteRepository: QuoteRepository
    let networkClient: Networking
    
    init(
        quoteRepository: QuoteRepository = MockQuoteRepository(),
        networkClient: Networking = NetworkClient(session: StubNetworkSession())
    ) {
        self.quoteRepository = quoteRepository
        self.networkClient = networkClient
    }
}
