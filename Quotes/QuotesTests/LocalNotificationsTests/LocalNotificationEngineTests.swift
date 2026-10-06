//
//  LocalNotificationEngineTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 06/10/2026.
//

import Testing
@testable import Quotes
import UserNotifications

@MainActor
struct LocalNotificationEngineTests {
    
    // MARK: - Authorisation Tests
    @Test("Requests authorisation from `UNUserNotificationCenter` singleton and gets backs success")
    func localNotificationEngine_requestAuthorisation_callsUnderlyingCenter_andReturnsSuccess() async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        mockRawNotificationCenter.stubbedAuthorisationResult = true
        
        let result = try await sut.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        
        #expect(mockRawNotificationCenter.requestAuthorisationCount == 1, "Should request authorisation once.")
        #expect(result, "Should be true.")
    }
    
    @Test("Requests authorisation from `UNUserNotificationCenter` singleton but gets an error")
    func localNotificationEngine_requestAuthorisation_callsUnderlyingCenter_whenSystemFails_returnsError() async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        mockRawNotificationCenter.shouldThrowError = true
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        do {
            _ = try await sut.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
            Issue.record("Engine should have thrown an error but succeeded instead.")
        } catch {
            #expect(mockRawNotificationCenter.requestAuthorisationCount == 1, "Should request authorisation once.")
        }
    }
    
    // MARK: - Notification Permission Test
    @Test(
        "All system permission states map correctly to domain entities",
        arguments: [
            (NotificationPermissionStatus.authorized, NotificationPermissionStatus.authorized),
            (.provisional, .provisional),
            (.denied, .denied),
            (.notDetermined, .notDetermined)
        ])
    func localNotificationEngine_fetchSettings_correctlyMapsAllPermissionStatuses(
        systemStatus: NotificationPermissionStatus,
        expectedDomainStatus: NotificationPermissionStatus
    ) async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        mockRawNotificationCenter.stubbedPermissionStatus = systemStatus
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        let config = await sut.fetchStatus()
        
        #expect(mockRawNotificationCenter.fetchCurrentStatusCount == 1, "Should have been called once.")
        #expect(config.status == expectedDomainStatus, "Should return the current permission status.")
    }
    
    // MARK: - Functional Execution Tests
    @Test("Schedules a request successfully with notification payload")
    func localNotificationEngine_schedule_addsARequestSuccessfully() async throws {
        let expectedID = "test_reminder_id"
        let content = UNMutableNotificationContent()
        content.title = "Test Title"
        content.body = "Test Body"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: expectedID,
            content: content,
            trigger: trigger
        )
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        try await sut.schedule(request)
        
        let interceptedRequest = mockRawNotificationCenter.scheduledRequests.first
        #expect(mockRawNotificationCenter.scheduledRequests.count == 1, "Should forward one request.")
        #expect(interceptedRequest?.identifier == expectedID, "The notification identifier was mutated or lost.")
        #expect(interceptedRequest?.content.title == "Test Title", "The payload title was altered.")
        #expect(interceptedRequest?.content.body == "Test Body", "The payload body was altered.")
    }
    
    @Test("Propagates error if system fails to schedule the request")
    func localNotificationEngine_schedule_whenSystemFails_propagatesSystemSchedulingFailure() async {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        mockRawNotificationCenter.shouldThrowError = true
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "failing_id",
            content: content,
            trigger: trigger
        )
        
        do {
            try await sut.schedule(request)
            Issue.record("Engine should have thrown an error but reported success instead.")
        } catch {
            #expect(mockRawNotificationCenter.scheduledRequests.count == 0, "No requests should be recorded on system failure.")
        }
    }
    
    @Test("Removes all pending requests")
    func localNotificationEngine_cancelAllPendingRequests_triggersRemoval() {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        sut.cancelAllPendingRequests()
        
        #expect(mockRawNotificationCenter.removeAllPendingRequestsCount == 1, "Should have been called once.")
    }
    
    @Test("Reset the notification badge count to zero successfully")
    func localNotificationEngine_resetBadge_updatesBadgeCountToZero() async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        try await sut.resetBadge()
        
        #expect(mockRawNotificationCenter.badgeCountSetTo == 0, "Should have been set to 0.")
    }
    
    @Test("Propagates error if reset the notification badge count to zero fails")
    func localNotificationEngine_resetBadge_whenSystemFails_propogatesFailure() async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        mockRawNotificationCenter.shouldThrowError = true
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        do {
            try await sut.resetBadge()
            Issue.record("Engine should have thrown an error but reported success instead.")
        } catch {
            #expect(mockRawNotificationCenter.badgeCountSetTo == nil, "Badge count reset should not happen on system failure.")
        }
    }
}


final class MockRawNotificationCenter: RawNotificationCentre {
    
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
