//
//  LocalNotificationsManagerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 06/10/2026.
//

import Testing
@testable import Quotes
import UserNotifications

@MainActor
struct LocalNotificationsManagerTests {

    // MARK: - Initialisation Tests
    @Test("On init, uses default time for local notification if user hasn't selected a different time")
    func localNotificationsManager_whenStorageIsEmpty_usesDefaultTime() {
        let (sut, _, _) = makeSUT(engineThrowsError: false)
        
        #expect(sut.scheduledTimeString == "10:00", "Manager failed to fallback to default time option.")
    }
    
    @Test("On init, loads time for local notification from `UserDefaults` if data exists")
    func localNotificationsManager_whenDataExists_loadsTimeFromStorage() {
        let mockEngine = MockNotificationEngine()
        let mockStorage = UserDefaultsHelper.makeUserDefaults(for: "LocalNotificationsManagerTests")
        let storedTime = "08:30"
        mockStorage.set(
            storedTime,
            forKey: "notificationTime"
        )
        
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        
        #expect(sut.scheduledTimeString == storedTime, "Manager failed to retrieve the stored time from storage.")
    }
    
    // MARK: - Permission And Related State Tracking Tests
    @Test("If requesting permission succeeds, update state correctly.")
    func localNotificationsManager_requestPermission_onSystemSuccess_updatesStateCorrectly() async {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        mockEngine.stubbedPermissionResult = true
        
        await sut.requestPermission()
        
        #expect(sut.isPermissionGranted, "Should be true.")
        #expect(sut.alertMessage == nil, "Should be nil.")
    }
    
    @Test("If user denies permission, alert message is set")
    func localNotificationsManager_requestPermission_ifUserDenies_updatesAlertMessage() async {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        mockEngine.stubbedPermissionResult = false
        
        await sut.requestPermission()
        
        #expect(sut.isPermissionGranted == false, "Should be false.")
        #expect(sut.alertMessage != nil, "Should not be nil.")
    }
    
    @Test("If system fails to execute permission request successfully, alert message is set")
    func localNotificationsManager_requestPermission_ifSystemFails_updatesAlertMessage() async {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: true)
        mockEngine.stubbedPermissionResult = false
        
        await sut.requestPermission()
        
        #expect(sut.isPermissionGranted == false, "Should be false.")
        #expect(sut.alertMessage != nil, "Should not be nil.")
    }
    
    @Test("Provisional and authorised are considered as permission granted",
          arguments: [
            NotificationPermissionStatus.authorized,
            NotificationPermissionStatus.provisional
          ])
    func localNotificationsManager_updatePermissionState_evaluatesProvisionalAndAuthorisedAsGrantedPermission(permissionStatus: NotificationPermissionStatus) async {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        mockEngine.stubbedConfig = NotificationConfig(status: permissionStatus)
        
        await sut.updatePermissionState()
        
        #expect(sut.isPermissionGranted, "Status \(permissionStatus) should have resolved to a granted permission state.")
    }
    
    @Test("Denied and not determined are considered as permission has not been granted",
          arguments: [
            NotificationPermissionStatus.denied,
            NotificationPermissionStatus.notDetermined
          ])
    func localNotificationsManager_updatePermissionState_evaluatesDeniedAndNotDeterminedAsPermissionNotGranted(permissionStatus: NotificationPermissionStatus) async {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        mockEngine.stubbedConfig = NotificationConfig(status: permissionStatus)
        
        await sut.updatePermissionState()
        
        #expect(sut.isPermissionGranted == false, "Status \(permissionStatus) should have resolved to a state where user hasn't granted permission.")
    }
    
    // MARK: - Notification Scheduling And Persistence Tests
    @Test("Scheduling a notification exits early without mutating state if time input is invalid")
    func localNotificationsManager_scheduleDailyNotification_ifInputIsInvalid_exitsEarly() async throws {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        let invalidInput = (hour: 25, minute: 64)
        let originalTime = sut.scheduledTimeString
        
        try await sut.scheduleDailyNotification(
            hour: invalidInput.hour,
            minute: invalidInput.minute
        )
        
        #expect(mockEngine.scheduledRequests.count == 0, "Should not have scheduled the request.")
        #expect(sut.scheduledTimeString == originalTime, "The time should not have changed.")
    }
    
    @Test("When scheduling notifications for user's chosen time, any previous requests are cancelled, and time is saved to `UserDefaults`")
    func localNotificationsManager_scheduleDailyNotification_clearsPreviousRequests_andPeristsUserChosenTime() async throws {
        let (sut, mockEngine, mockStorage) = makeSUT(engineThrowsError: false)
        let targetTime = (hour: 08, minute: 15)
        let targetTimeString = "08:15"
        
        try await sut.scheduleDailyNotification(
            hour: targetTime.hour,
            minute: targetTime.minute
        )
        
        #expect(mockEngine.cancelRequestsCount == 1, "Should call method once to wipe existing stale entries before scheduling.")
        #expect(mockEngine.scheduledRequests.count == 1, "Should queue up exactly one request.")
        #expect(sut.scheduledTimeString == targetTimeString, "Should have updated this state from default.")
        
        #expect(mockStorage.string(forKey: "notificationTime") == targetTimeString, "The manager failed to save the configuration string to key-value disk memory.")
        
        let request = mockEngine.scheduledRequests.first
        let trigger = request?.trigger as? UNCalendarNotificationTrigger
        #expect(trigger?.dateComponents.hour == targetTime.hour, "Should be the hour passed in as a parameter.")
        #expect(trigger?.dateComponents.minute == targetTime.minute, "Should be the hour passed in as a parameter.")
        #expect(trigger?.repeats == true, "Should be true.")
    }
    
    // MARK: - Badge Clearing Tests
    @Test("Clears the app badge via the engine method")
    func localNotificationsManager_clearAppBadge_successfullyInvokesEngineReset() async throws {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: false)
        
        try await sut.clearAppBadge()
        
        #expect(mockEngine.resetBadgeCount == 1, "The manager failed to call the badge reset function on the engine.")
    }
        
    @Test("If clearing the app badge fails, propagate error")
    func localNotificationsManager_clearAppBadge_whenEngineFails_propagatesError() async throws {
        let (sut, mockEngine, _) = makeSUT(engineThrowsError: true)
                
        do {
            try await sut.clearAppBadge()
            Issue.record("Manager should have thrown an execution error on badge clearing failure, but reported success instead.")
        } catch {
            #expect(mockEngine.resetBadgeCount == 0, "Should be zero on system failure.")
        }
    }
    
    //MARK: - SUT Helper
    private func makeSUT(engineThrowsError: Bool) -> (
        sut: LocalNotificationsManager,
        mockEngine: MockNotificationEngine,
        mockStorage: UserDefaults
    ) {
        let mockEngine = MockNotificationEngine()
        mockEngine.shouldThrowError = engineThrowsError
        let mockStorage = UserDefaultsHelper.makeUserDefaults(for: "LocalNotificationsManagerTests")
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        return (sut, mockEngine, mockStorage)
    }
}
