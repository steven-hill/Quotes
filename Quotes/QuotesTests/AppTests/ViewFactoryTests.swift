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
    func viewFactory_makeQuoteOfTheDayView_accessesNetworkClient() {
        let spy = DependencyContainerSpy()
        let sut = ViewFactory(dependencies: spy)
        
        _ = sut.makeQuoteOfTheDayView()
        
        #expect(spy.didAccessNetworkClient, "Should have got the network client instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses quote repository for `ReflectOnQuoteView`")
    func viewFactory_makeReflectOnQuoteView_accessesQuoteRepository() {
        let spy = DependencyContainerSpy()
        let sut = ViewFactory(dependencies: spy)
        
        _ = sut.makeReflectOnQuoteView(
            quoteContent: Quote.sample[0].text,
            quoteAuthor: Quote.sample[0].author,
            successfulSave: {}
        )
        
        #expect(spy.didAccessQuoteRepository, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses quote repository for `SavedView`")
    func viewFactory_makeSavedView_accessesQuoteRepository() {
        let spy = DependencyContainerSpy()
        let sut = ViewFactory(dependencies: spy)
        
        _ = sut.makeSavedView()
        
        #expect(spy.didAccessQuoteRepository, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses quote repository for `EditReflectionView`")
    func viewFactory_makeEditReflectionView_accessesQuoteRepository() {
        let spy = DependencyContainerSpy()
        let sut = ViewFactory(dependencies: spy)
        
        _ = sut.makeEditReflectionView(
            savedQuote: Quote.sample[0],
            userThoughts: "Reflection",
            successfulSave: {},
            refreshList: {}
        )
        
        #expect(spy.didAccessQuoteRepository, "Should have got the quote repository instance from the dependencies.")
    }
    
    @Test("View factory successfully accesses appearance manager for `SettingsView`")
    func viewFactory_makeSettingsView_accessesAppearanceManager()  {
        let spy = DependencyContainerSpy()
        let sut = ViewFactory(dependencies: spy)
        
        _ = sut.makeSettingsView()
        
        #expect(spy.didAccessAppearanceManager, "Should have got the appearance manager instance from the dependencies.")
    }
    
    //MARK: - Spy
    private final class DependencyContainerSpy: AppDependencyContaining {
        // MARK: - Properties
        private let mockQuoteRepository: QuoteRepository
        private let mockNetworkClient: Networking
        private let mockAppearanceManager: AppearanceManager
        
        // MARK: - Tracking States
        private(set) var didAccessQuoteRepository = false
        private(set) var didAccessNetworkClient = false
        private(set) var didAccessAppearanceManager = false
        
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
            appearanceManager: AppearanceManager = AppearanceManager(store: UserDefaultsHelper.makeUserDefaults(for: "ViewFactoryTests"))
        ) {
            self.mockQuoteRepository = quoteRepository
            self.mockNetworkClient = networkClient
            self.mockAppearanceManager = appearanceManager
        }
    }

    //MARK: - Mock Network Session
    private struct MockNetworkSession: NetworkSession {
        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            return (Data(), URLResponse())
        }
    }
}
