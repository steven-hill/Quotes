//
//  AppearanceManagerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 01/10/2026.
//

import Testing
@testable import Quotes
import Foundation

@MainActor
struct AppearanceManagerTests {

    @Test("If nothing has been persisted to `UserDefaults`, fall back to `system`")
    func appearanceManager_defaultsToSystem() {
        let sut = AppearanceManager(store: makeUserDefaults())

        #expect(sut.selectedAppearance == .system)
    }
    
    //MARK: - Helper Method
    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "AppearanceManagerTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
