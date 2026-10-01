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
    
    @Test("Load the user's preference from `UserDefaults`")
    func appearanceManager_loadsSavedAppearance() {
        let defaults = makeUserDefaults()
        defaults.set(Appearance.dark.rawValue, forKey: "selectedAppearance")

        let sut = AppearanceManager(store: defaults)

        #expect(sut.selectedAppearance == .dark)
    }
    
    @Test("When the user changes the device's appearance, the change is saved")
    func appearanceManager_savesAppearanceToUserDefaults() {
        let defaults = makeUserDefaults()
        let sut = AppearanceManager(store: defaults)

        sut.selectedAppearance = .light

        #expect(defaults.string(forKey: "selectedAppearance") == Appearance.light.rawValue)
        
        sut.selectedAppearance = .dark

        #expect(defaults.string(forKey: "selectedAppearance") == Appearance.dark.rawValue)
        
        sut.selectedAppearance = .system

        #expect(defaults.string(forKey: "selectedAppearance") == Appearance.system.rawValue)
    }
    
    //MARK: - Helper Method
    private func makeUserDefaults() -> UserDefaults {
        let suiteName = "AppearanceManagerTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
