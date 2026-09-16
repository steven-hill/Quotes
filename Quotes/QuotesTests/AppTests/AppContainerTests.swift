//
//  AppContainerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2026.
//

import Testing
@testable import Quotes

@MainActor
struct AppContainerTests {

    @Test("Initialisation succeeds and initialises dependencies")
    func appContainer_init_succeeds() throws {
        let sut = try AppContainer(isInMemoryOnly: true)
        
        #expect(sut.isRunningInDegradedMode == false, "Should be false.")
    }
}
