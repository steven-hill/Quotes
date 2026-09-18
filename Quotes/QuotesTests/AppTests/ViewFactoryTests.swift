//
//  ViewFactoryTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 18/09/2026.
//

import Testing
import Foundation
@testable import Quotes

@MainActor
struct ViewFactoryTests {

    @Test("View factory successfully accesses network client for `QuoteOfTheDayView`")
    func viewFactory_makeQuoteOfTheDayView_pullsCorrectDependencyFromAppDependencies() {
        let mockDependencyContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockDependencyContainer)
        
        _ = sut.makeQuoteOfTheDayView()
                
        #expect(mockDependencyContainer.didAccessNetworkClient == true, "Should have got the network client instance from the dependencies.")
    }
}

final class MockDependencyContainer: AppDependencyContaining {
    
    // MARK: - Properties
    private let mockQuoteRepository: QuoteRepository
    private let mockNetworkClient: Networking
    
    // MARK: - Tracking States
    var didAccessQuoteRepository = false
    var didAccessNetworkClient = false
    var quoteRepository: QuoteRepository {
        didAccessQuoteRepository = true
        return mockQuoteRepository
    }
    
    var networkClient: Networking {
        didAccessNetworkClient = true
        return mockNetworkClient
    }
    
    // MARK: - Initialisation
    init(
        quoteRepository: QuoteRepository = MockQuoteRepository(),
        networkClient: Networking = NetworkClient(session: MockNetworkSession())
    ) {
        self.mockQuoteRepository = quoteRepository
        self.mockNetworkClient = networkClient
    }
}

struct MockNetworkSession: NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return (Data(), URLResponse())
    }
}
