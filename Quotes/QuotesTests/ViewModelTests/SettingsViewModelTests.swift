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

    // MARK: - Initialisation Tests
    @Test("On init synchronise its time property with manager's scheduled time string")
    func settingsViewModel_onInit_syncsItsTimePropertyWithScheduledTime() {
        let mockStorage = UserDefaultsHelper.makeUserDefaults(for: "SettingsViewModelTests")
        mockStorage.set(
            "08:30",
            forKey: "notificationTime"
        )
        let localNotificationsManager = LocalNotificationsManager(storage: mockStorage)
        let sut = SettingsViewModel(localNotificationsManager: localNotificationsManager)
        
        let (hour, minute) = getHourAndMinute(from: sut.notificationTime)
        #expect(hour == 8, "Should match what was stored by user.")
        #expect(minute == 30, "Should match what was stored by user.")
    }
    
    @Test("On init if no time has been stored previously by the userc")
    func settingsViewModel_onInit_ifNoTimeWasPersisted_fallbackToDefaultTime() {
        let localNotificationsManager = LocalNotificationsManager(storage: UserDefaultsHelper.makeUserDefaults(for: "SettingsViewModelTests"))
        let sut = SettingsViewModel(localNotificationsManager: localNotificationsManager)
        
        let (hour, minute) = getHourAndMinute(from: sut.notificationTime)
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
        
        let (hour, minute) = getHourAndMinute(from: sut.notificationTime)
        #expect(hour == 10, "Should match the default time.")
        #expect(minute == 00, "Should match the default time.")
    }
    
    // MARK: - Request Permission Test
    @Test("VM triggers service permission prompt, and, if granted, schedules notification with default time")
    func settingsViewModel_requestPermissionAndSchedule_whenUserGrantsPermission_schedulesNotification() async {
        let spy = NotificationServiceSpy()
        spy.isPermissionGranted = true
        let sut = SettingsViewModel(localNotificationsManager: spy)
        
        await sut.requestPermissionAndSchedule()
        
        #expect(spy.requestPermissionCallCount == 1, "Should have called method once.")
        #expect(spy.scheduleReminderCalledWith != nil, "Should auto-schedule default time upon permission being granted.")
        #expect(spy.scheduleReminderCalledWith?.hour == 10, "Should match the default notification time.")
        #expect(spy.scheduleReminderCalledWith?.minute == 00, "Should match the default notification time.")
        #expect(sut.isShowingAlert == false, "An alert was shown despite permission being granted successfully.")
    }
    
    @Test("VM triggers service permission prompt, and, if denied, handles service's alert message and updates state")
    func settingsViewModel_requestPermissionAndSchedule_whenPermissionIsDenied_handlesAlertMessageAndState() async {
        let spy = NotificationServiceSpy()
        spy.alertMessage = "" // Makes it not nil to simulate message provided by service.
        let sut = SettingsViewModel(localNotificationsManager: spy)
        
        await sut.requestPermissionAndSchedule()
        
        #expect(spy.requestPermissionCallCount == 1, "Should have called method once.")
        #expect(spy.scheduleReminderCalledWith == nil, "VM should never attempt to schedule notifications if permission is denied.")
        #expect(sut.isShowingAlert, "An alert should be shown.")
        #expect(sut.alertMessage != nil, "Should show the alert message from the service.")
    }

    @Test("VM triggers service permission prompt, and, if denied, shows fallback alert message if service doesn't provide one, and updates state")
    func settingsViewModel_requestPermissionAndSchedule_whenPermissionIsDeniedButServiceDoesntProvideMessage_handlesAlertMessageAndState() async {
        let spy = NotificationServiceSpy()
        let sut = SettingsViewModel(localNotificationsManager: spy)
        
        await sut.requestPermissionAndSchedule()
        
        #expect(spy.requestPermissionCallCount == 1, "Should have called method once.")
        #expect(spy.scheduleReminderCalledWith == nil, "VM should never attempt to schedule notifications if permission is denied.")
        #expect(sut.isShowingAlert, "An alert should be shown.")
        #expect(sut.alertMessage != nil, "Should show the fallback message because service didn't provide one.")
    }
    
    // MARK: - Set New Notification Time Tests
    @Test("When user chooses a new notification delivery time, VM extracts time components and calls service")
    func settingsViewModel_setNewNotificationTime_correctlyExtractsUIComponents_andInvokesService() async {
        let spy = NotificationServiceSpy()
        let sut = SettingsViewModel(localNotificationsManager: spy)
        sut.notificationTime = createMockDate(
            hour: 16,
            minute: 45
        )
        
        await sut.setNewNotificationTime()
        
        #expect(spy.scheduleReminderCalledWith != nil, "ViewModel failed to call the service layer.")
        #expect(spy.scheduleReminderCalledWith?.hour == 16, "Should match the updated notification time.")
        #expect(spy.scheduleReminderCalledWith?.minute == 45, "Should match the updated notification time.")
    }
    
    @Test("When user chooses a new notification delivery time but service fails, VM handles alert message and updates state")
    func settingsViewModel_setNewNotificationTime_serviceFails_handlesAlertMessageAndUpdatesState() async {
        let spy = NotificationServiceSpy()
        spy.shouldThrowError = true
        let sut = SettingsViewModel(localNotificationsManager: spy)
        sut.notificationTime = createMockDate(
            hour: 16,
            minute: 45
        )
        
        await sut.setNewNotificationTime()
        
        #expect(spy.scheduleReminderCalledWith == nil, "Should be nil because service layer failed to set new time.")
        #expect(sut.isShowingAlert, "An alert should be shown.")
        #expect(sut.alertMessage != nil, "Should show the alert message from the service.")
    }
    
    // MARK: - Notification Service Spy
    final class NotificationServiceSpy: NotificationService {
        // Required properties
        var isPermissionGranted = false
        var alertMessage: String?
        var scheduledTimeString = "10:00"
        
        // Error boolean
        var shouldThrowError = false
        
        // Spies
        private(set) var requestPermissionCallCount = 0
        private(set) var scheduleReminderCalledWith: (hour: Int, minute: Int)?

        // Methods
        func requestPermission() async {
            requestPermissionCallCount += 1
        }
        
        func updatePermissionState() async {}
        
        func scheduleDailyNotification(
            hour: Int,
            minute: Int
        ) async throws {
            if shouldThrowError {
                throw NSError(
                    domain: "scheduleDailyNotificationTest",
                    code: -1,
                    userInfo: nil
                )
            }
            scheduleReminderCalledWith = (hour, minute)
        }
        
        func clearAppBadge() async throws {}
    }
    
    //MARK: - Helpers
    private func getHourAndMinute(from time: Date) -> (
        hour: Int,
        minute: Int
    ) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        return (hour, minute)
    }
    
    private func createMockDate(
        hour: Int,
        minute: Int
    ) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
