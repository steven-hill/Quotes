//
//  MockNotificationEngine.swift
//  QuotesTests
//
//  Created by Steven Hill on 06/10/2026.
//

import UserNotifications
@testable import Quotes

final class MockNotificationEngine: NotificationCentreEngine {
    
    //MARK: - Stub Properties
    var stubbedPermissionResult = true
    var stubbedConfig = NotificationConfig(status: .notDetermined)
    var shouldThrowError = false
    
    //MARK: - Spy Variables
    private(set) var cancelRequestsCount = 0
    private(set) var resetBadgeCount = 0
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
    
    func resetBadge() async throws {
        if shouldThrowError { throw NSError(domain: "Test", code: -1) }
        resetBadgeCount += 1
    }
}
