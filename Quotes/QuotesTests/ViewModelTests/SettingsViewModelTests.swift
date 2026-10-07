//
//  SettingsViewModelTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 07/10/2026.
//

import Testing
@testable import Quotes
import Foundation

@MainActor
struct SettingsViewModelTests {

    // MARK: - Initialization Tests
    @Test("On init synchronise its time property with manager's scheduled time string")
    func settingsViewModel_onInit_syncsItsTimePropertyWithScheduledTime() {
        let mockStorage = UserDefaultsHelper.makeUserDefaults(for: "SettingsViewModelTests")
        mockStorage.set(
            "08:30",
            forKey: "notificationTime"
        )
        let localNotificationsManager = LocalNotificationsManager(storage: mockStorage)
        let sut = SettingsViewModel(localNotificationsManager: localNotificationsManager)
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sut.notificationTime)
        let minute = calendar.component(.minute, from: sut.notificationTime)
        #expect(hour == 8, "Should match what was stored by user.")
        #expect(minute == 30, "Should match what was stored by user.")
    }
    
    @Test("On init if no time has been stored previously by the userc")
    func settingsViewModel_onInit_ifNoTimeWasPersisted_fallbackToDefaultTime() {
        let localNotificationsManager = LocalNotificationsManager(storage: UserDefaultsHelper.makeUserDefaults(for: "SettingsViewModelTests"))
        let sut = SettingsViewModel(localNotificationsManager: localNotificationsManager)
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sut.notificationTime)
        let minute = calendar.component(.minute, from: sut.notificationTime)
        #expect(hour == 10, "Should match the default time.")
        #expect(minute == 00, "Should match the default time.")
    }
    
    @Test("On init if stored time can't be parsed successfully, fall back to default time")
    func settingsViewModel_onInit_ifTimeCantBeParsed_fallbackToDefaultTime() {
        let mockStorage = UserDefaultsHelper.makeUserDefaults(for: "SettingsViewModelTests")
        mockStorage.set(
            "InvalidTimeFormat",
            forKey: "notificationTime"
        )
        let localNotificationsManager = LocalNotificationsManager(storage: mockStorage)
        let sut = SettingsViewModel(localNotificationsManager: localNotificationsManager)
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: sut.notificationTime)
        let minute = calendar.component(.minute, from: sut.notificationTime)
        #expect(hour == 10, "Should match the default time.")
        #expect(minute == 00, "Should match the default time.")
    }
}
