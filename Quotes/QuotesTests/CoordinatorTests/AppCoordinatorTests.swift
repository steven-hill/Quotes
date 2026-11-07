//
//  AppCoordinatorTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 07/11/2026.
//

import Testing
@testable import Quotes
import Foundation
import UIKit

@MainActor
struct AppCoordinatorTests {

    @Test("Coordinator calls `UIApplicationURLHandler` once to open the device's Settings app")
    func appCoordinator_openSettingsApp_callsURLHandler() {
        let urlHandlerSpy = URLHandlerSpy()
        let sut = AppCoordinator(urlHandler: urlHandlerSpy)
        
        sut.openSettingsApp()
        
        #expect(urlHandlerSpy.openCallCount == 1, "Should call the URL Handler once.")
    }
    
    @Test("Coordinator calls `UIApplicationURLHandler` uses the correct Settings URL")
    func appCoordinator_openSettingsApp_opensCorrectURL() {
        let urlHandlerSpy = URLHandlerSpy()
        let sut = AppCoordinator(urlHandler: urlHandlerSpy)
        
        sut.openSettingsApp()
        
        #expect(urlHandlerSpy.openedURL == URL(string: UIApplication.openSettingsURLString), "Should call the correct URL.")
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
