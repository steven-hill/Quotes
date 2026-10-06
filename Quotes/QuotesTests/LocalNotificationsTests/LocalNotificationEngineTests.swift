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
    @Test("Removes all pending requests")
    func localNotificationEngine_cancelAllPendingRequests_triggersRemoval() {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        let sut = LocalNotificationEngine(centre: mockRawNotificationCenter)
        
        sut.cancelAllPendingRequests()
        
        #expect(mockRawNotificationCenter.removeAllPendingRequestsCount == 1, "Should have been called once.")
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
    private(set) var removeAllPendingRequestsCount = 0
    
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
    
    func removeAllPendingNotificationRequests() {
        removeAllPendingRequestsCount += 1
    }
}
