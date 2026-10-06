//
//  MockRawNotificationCentre.swift
//  QuotesTests
//
//  Created by Steven Hill on 06/10/2026.
//

import Foundation
@testable import Quotes
import UserNotifications

final class MockRawNotificationCentre: RawNotificationCentre {
    
    //MARK: - Stub Properties
    var stubbedAuthorisationResult = true
    var stubbedPermissionStatus: NotificationPermissionStatus = .authorized
    var shouldThrowError = false
    
    //MARK: - Spy Variables
    private(set) var requestAuthorisationCount = 0
    private(set) var fetchCurrentStatusCount = 0
    private(set) var scheduledRequests: [UNNotificationRequest] = []
    private(set) var removeAllPendingRequestsCount = 0
    private(set) var badgeCountSetTo: Int?
    
    //MARK: - Methods
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorisationCount += 1
        if shouldThrowError {
            throw NSError(
                domain: "requestAuthorisationTest",
                code: -1,
                userInfo: nil
            )
        }
        return stubbedAuthorisationResult
    }
    
    func fetchCurrentStatus() async -> NotificationPermissionStatus {
        fetchCurrentStatusCount += 1
        return stubbedPermissionStatus
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        if shouldThrowError {
            throw NSError(
                domain: "addNotificationRequestTest",
                code: -1,
                userInfo: nil
            )
        }
        scheduledRequests.append(request)
    }
    
    func removeAllPendingNotificationRequests() {
        removeAllPendingRequestsCount += 1
    }
    
    func setBadgeCount(_ count: Int) async throws {
        if shouldThrowError {
            throw NSError(
                domain: "resetBadgeCountTest",
                code: -1,
                userInfo: nil
            )
        }
        badgeCountSetTo = count
    }
}
