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
        mockStorage.storage["notificationTime"] = nil
        
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
    var stubbedConfig = NotificationConfig(status: .authorized)
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
