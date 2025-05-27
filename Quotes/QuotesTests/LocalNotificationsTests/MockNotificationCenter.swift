//
//  MockNotificationCenter.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/04/2025.
//

import XCTest
@testable import Quotes

final class MockNotificationCenter: NotificationCenterProtocol {
    var requestAuthorizationCalled = false
    var shouldThrowAuthorizationError = false
    var addCalled = false
    var removeAllPendingNotificationRequestsCalled = false
    var shouldThrowAddError = false
    var mockSettings: NotificationSettings = .init(authorizationStatus: .authorized)
    var badgeCount = 0
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws {
        requestAuthorizationCalled = true
        if shouldThrowAuthorizationError {
            throw NSError(domain: "Test", code: 1)
        }
    }
    
    func notificationSettings() async -> NotificationSettings {
        return mockSettings
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        addCalled = true
        if shouldThrowAddError {
            throw NSError(domain: "Test", code: 2)
        }
    }
    
    func removeAllPendingNotificationRequests() {
        removeAllPendingNotificationRequestsCalled = true
    }
    
    func setBadgeCountToZero() {
        badgeCount = 0
    }
}
