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
    
    @Test("View factory successfully accesses quote repository for `ReflectOnQuoteView`")
    func viewFactory_makeReflectOnQuoteView_pullsCorrectDependencyFromAppDependencies() {
        let mockDependencyContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockDependencyContainer)
        
        _ = sut.makeReflectOnQuoteView(
            quoteContent: Quote.sample[0].text,
            quoteAuthor: Quote.sample[0].author,
            successfulSave: {}
        )
        
        #expect(mockDependencyContainer.didAccessQuoteRepository == true, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses quote repository for `SavedView`")
    func viewFactory_makeSavedView_pullsCorrectDependencyFromAppDependencies() {
        let mockContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockContainer)
        
        _ = sut.makeSavedView()
        
        #expect(mockContainer.didAccessQuoteRepository == true, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses quote repository for `EditReflectionView`")
    func viewFactory_makeEditReflectionView_pullsCorrectDependencyFromAppDependencies() {
        let mockDependencyContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockDependencyContainer)
        
        _ = sut.makeEditReflectionView(
            savedQuote: Quote.sample[0],
            userThoughts: "Reflection",
            successfulSave: {},
            refreshList: {}
        )
        
        #expect(mockDependencyContainer.didAccessQuoteRepository == true, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses appearance manager for `SettingsView`")
    func viewFactory_makeSettingsView_accessesAppearanceManager()  {
        let mockDependencyContainer = MockDependencyContainer()
        let sut = ViewFactory(dependencies: mockDependencyContainer)
        
        _ = sut.makeSettingsView()
        
        #expect(mockDependencyContainer.didAccessAppearanceManager, "Should have got the appearance manager instance from the dependencies.")
    }
    
    //MARK: - Mocks
    private final class MockDependencyContainer: AppDependencyContaining {
        
        // MARK: - Properties
        private let mockQuoteRepository: QuoteRepository
        private let mockNetworkClient: Networking
        private let mockAppearanceManager: AppearanceManager
        
        // MARK: - Tracking States
        var didAccessQuoteRepository = false
        var didAccessNetworkClient = false
        var didAccessAppearanceManager = false
        
        var quoteRepository: QuoteRepository {
            didAccessQuoteRepository = true
            return mockQuoteRepository
        }
        var networkClient: Networking {
            didAccessNetworkClient = true
            return mockNetworkClient
        }
        var appearanceManager: AppearanceManager {
            didAccessAppearanceManager = true
            return mockAppearanceManager
        }
        
        // MARK: - Initialisation
        init(
            quoteRepository: QuoteRepository = MockQuoteRepository(),
            networkClient: Networking = NetworkClient(session: MockNetworkSession()),
            appearanceManager: AppearanceManager = AppearanceManager()
        ) {
            self.mockQuoteRepository = quoteRepository
            self.mockNetworkClient = networkClient
            self.mockAppearanceManager = appearanceManager
        }
    }

    private struct MockNetworkSession: NetworkSession {
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            return (Data(), URLResponse())
        }
    }
}
