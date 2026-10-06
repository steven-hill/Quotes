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
        let mockEngine = MockNotificationEngine()
        let mockStorage = MockPreferencesStorage()
        
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        
        #expect(sut.scheduledTimeString == "10:00", "Manager failed to fallback to default time option.")
    }
    
    @Test("On init, loads time for local notification from `UserDefaults` if data exists")
    func localNotificationsManager_whenDataExists_loadsTimeFromStorage() {
        let mockEngine = MockNotificationEngine()
        let mockStorage = MockPreferencesStorage()
        let storedTime = "08:30"
        mockStorage.storage["notificationTime"] = storedTime
        
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        
        #expect(sut.scheduledTimeString == storedTime, "Manager failed to retrieve the stored time from storage.")
    }
    
    // MARK: - Permission And Related State Tracking Tests
    @Test("If requesting permission succeeds, update state correctly.")
    func localNotificationsManager_requestPermission_onSystemSuccess_updatesStateCorrectly() async {
        let mockEngine = MockNotificationEngine()
        let mockStorage = MockPreferencesStorage()
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        mockEngine.stubbedPermissionResult = true
        
        await sut.requestPermission()
        
        #expect(sut.isPermissionGranted, "Should be true.")
        #expect(sut.alertMessage == nil, "Should be nil.")
    }
    
    @Test("If user denies permission, alert message is set")
    func localNotificationsManager_requestPermission_ifUserDenies_updatesAlertMessage() async {
        let mockEngine = MockNotificationEngine()
        let mockStorage = MockPreferencesStorage()
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        mockEngine.stubbedPermissionResult = false
        
        await sut.requestPermission()
        
        #expect(sut.isPermissionGranted == false, "Should be false.")
        #expect(sut.alertMessage != nil, "Should not be nil.")
    }
    
    @Test("If system fails to execute permission request successfully, alert message is set")
    func localNotificationsManager_requestPermission_ifSystemFails_updatesAlertMessage() async {
        let mockEngine = MockNotificationEngine()
        mockEngine.shouldThrowError = true
        let mockStorage = MockPreferencesStorage()
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
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
        let mockEngine = MockNotificationEngine()
        mockEngine.stubbedConfig = NotificationConfig(status: permissionStatus)
        let mockStorage = MockPreferencesStorage()
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        
        await sut.updatePermissionState()
        
        #expect(sut.isPermissionGranted, "Status \(permissionStatus) should have resolved to a granted permission state.")
    }
    
    @Test("Denied and not determined are considered as permission has not been granted",
          arguments: [
            NotificationPermissionStatus.denied,
            NotificationPermissionStatus.notDetermined
          ])
    func localNotificationsManager_updatePermissionState_evaluatesDeniedAndNotDeterminedAsPermissionNotGranted(permissionStatus: NotificationPermissionStatus) async {
        let mockEngine = MockNotificationEngine()
        mockEngine.stubbedConfig = NotificationConfig(status: permissionStatus)
        let mockStorage = MockPreferencesStorage()
        let sut = LocalNotificationsManager(
            engine: mockEngine,
            storage: mockStorage
        )
        
        await sut.updatePermissionState()
        
        #expect(sut.isPermissionGranted == false, "Status \(permissionStatus) should have resolved to a state where user hasn't granted permission.")
    }
}

// MARK: - Mock Preferences Storage
final class MockPreferencesStorage: AppPreferencesStorage {
    var storage: [String: String] = [:]
    
    func string(forKey key: String) -> String? {
        return storage[key]
    }
    
    func setString(
        _ value: String,
        forKey key: String
    ) {
        storage[key] = value
    }
}

// MARK: - Mock Notification Engine
final class MockNotificationEngine: NotificationCentreEngine {
    
    //MARK: - Stub Properties
    var stubbedPermissionResult = true
    var stubbedConfig = NotificationConfig(status: .notDetermined)
    var shouldThrowError = false
    
    //MARK: - Spy Variables
    private(set) var cancelRequestsCount = 0
    private(set) var scheduledRequests: [UNNotificationRequest] = []
    
    //MARK: - Methods
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "Test", code: -1) }
        return stubbedPermissionResult
    }
    
    func fetchStatus() async -> NotificationConfig {
        return stubbedConfig
    }
    
    func schedule(_ request: UNNotificationRequest) async throws {
        if shouldThrowError { throw NSError(domain: "Test", code: -1) }
        scheduledRequests.append(request)
    }
    
    func cancelAllPendingRequests() {
        cancelRequestsCount += 1
    }
    
    func resetBadge() async throws {}
}
