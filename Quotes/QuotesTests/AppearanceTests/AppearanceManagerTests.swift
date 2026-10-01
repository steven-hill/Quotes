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
        let sut = AppearanceManager(store: UserDefaultsHelper.makeUserDefaults(for: "AppearanceManagerTests"))

        #expect(sut.selectedAppearance == .system)
    }
    
    @Test("Load the user's preference from `UserDefaults`")
    func appearanceManager_loadsSavedAppearance() {
        let defaults = UserDefaultsHelper.makeUserDefaults(for: "AppearanceManagerTests")
        defaults.set(Appearance.dark.rawValue, forKey: Constants.UserDefaultsAppearanceKey.key)

        let sut = AppearanceManager(store: defaults)

        #expect(sut.selectedAppearance == .dark)
    }
    
    @Test("When the user changes the device's appearance, the change is saved")
    func appearanceManager_savesAppearanceToUserDefaults() {
        let defaults = UserDefaultsHelper.makeUserDefaults(for: "AppearanceManagerTests")
        let sut = AppearanceManager(store: defaults)

        sut.selectedAppearance = .light

        #expect(defaults.string(forKey: Constants.UserDefaultsAppearanceKey.key) == Appearance.light.rawValue)
        
        sut.selectedAppearance = .dark

        #expect(defaults.string(forKey: Constants.UserDefaultsAppearanceKey.key) == Appearance.dark.rawValue)
        
        sut.selectedAppearance = .system

        #expect(defaults.string(forKey: Constants.UserDefaultsAppearanceKey.key) == Appearance.system.rawValue)
    }
}
