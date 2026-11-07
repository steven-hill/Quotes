//
//  AppCoordinatorTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 07/11/2026.
//

import Testing
@testable import Quotes
import Foundation

@MainActor
struct AppCoordinatorTests {

    @Test func appCoordinator_openSettingsApp_callsURLHandler() {
        let urlHandlerSpy = URLHandlerSpy()
        let sut = AppCoordinator(urlHandler: urlHandlerSpy)
        
        sut.openSettingsApp()
        
        #expect(urlHandlerSpy.openCallCount == 1, "Should call the URL Handler once.")
    }
    
    // MARK: - URL Handler Spy
    final class URLHandlerSpy: URLOpening {

        private(set) var openedURL: URL?
        private(set) var openCallCount = 0

        func open(_ url: URL) {
            openedURL = url
            openCallCount += 1
        }
    }
}
