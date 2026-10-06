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
        let sut = LocalNotificationEngine(center: mockRawNotificationCenter)
        mockRawNotificationCenter.stubbedAuthorisationResult = true
        
        let result = try await sut.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        
        #expect(mockRawNotificationCenter.requestAuthorisationCount == 1, "Should request authorisation once.")
        #expect(result, "Should be true.")
    }
    
    @Test("Requests authorisation from `UNUserNotificationCenter` singleton with success")
    func localNotificationEngine_requestAuthorisation_callsUnderlyingCenter_whenSystemFails_returnsError() async throws {
        let mockRawNotificationCenter = MockRawNotificationCenter()
        mockRawNotificationCenter.shouldThrowError = true
        let sut = LocalNotificationEngine(center: mockRawNotificationCenter)
        
        do {
            _ = try await sut.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
            Issue.record("Engine should have thrown an error but succeeded instead.")
        } catch {
            #expect(mockRawNotificationCenter.requestAuthorisationCount == 1)
        }
    }
}


final class MockRawNotificationCenter: RawNotificationCentre {
    var stubbedAuthorisationResult = true
    var shouldThrowError = false
    
    //MARK: - Spy variables
    private(set) var requestAuthorisationCount = 0
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestAuthorisationCount += 1
        if shouldThrowError {
            throw NSError(domain: "requestAuthorisationTest", code: -1, userInfo: nil)
        }
        return stubbedAuthorisationResult
    }
}
