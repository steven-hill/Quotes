//
//  LocalNotificationManager.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/04/2025.
//

import XCTest
@testable import Quotes

@MainActor
final class LocalNotificationManagerTests: XCTestCase {
    
    private var mockNotificationCenter: MockNotificationCenter!
    private var mockApplication: MockApplication!
    private var sut: LocalNotificationManager!
    
    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockNotificationCenter()
        mockApplication = MockApplication()
        sut = LocalNotificationManager(notificationCenter: mockNotificationCenter, application: mockApplication)
    }
    
    override func tearDown() {
        super.tearDown()
        mockNotificationCenter = nil
        mockApplication = nil
        sut = nil
    }
    
    func test_requestAuthorizationSuccess() async throws {
        try await sut.requestAuthorization()
        
        XCTAssertTrue(mockNotificationCenter.requestAuthorizationCalled, "Notification centre request authorization should be called.")
        XCTAssertFalse(sut.hasError, "There should not be an error.")
    }
    
    func test_requestAuthorizationFailure() async throws {
        mockNotificationCenter.shouldThrowAuthorizationError = true
        
        do {
            _ = try await sut.requestAuthorization()
            XCTFail("Expected to throw.")
        } catch {
            XCTAssertTrue(sut.hasError, "There should be be an error.")
            XCTAssertEqual(sut.notificationError, .requestAuthorizationFailure, "`NotificationError` should be .requestAuthorizationFailure.")
        }
    }
    
    func test_getCurrentAuthorizationSetting_forAuthorized() async {
        mockNotificationCenter.mockSettings = NotificationSettings(authorizationStatus: .authorized)
        
        await sut.getCurrentAuthorizationSetting()
        
        XCTAssertTrue(sut.authorizationGranted, "Authorization should be granted.")
    }
    
    func test_getCurrentAuthorizationSetting_forDenied() async {
        mockNotificationCenter.mockSettings = NotificationSettings(authorizationStatus: .denied)
        
        await sut.getCurrentAuthorizationSetting()
        
        XCTAssertFalse(sut.authorizationGranted, "Authorization should be not granted.")
    }
    
    func test_getCurrentAuthorizationSetting_forNotDetermined() async {
        mockNotificationCenter.mockSettings = NotificationSettings(authorizationStatus: .notDetermined)
        
        await sut.getCurrentAuthorizationSetting()
        
        XCTAssertFalse(sut.authorizationGranted, "Authorization should be not granted.")
    }
    
    func test_getCurrentAuthorizationSetting_forProvisional() async {
        mockNotificationCenter.mockSettings = NotificationSettings(authorizationStatus: .provisional)
        
        await sut.getCurrentAuthorizationSetting()
        
        XCTAssertFalse(sut.authorizationGranted, "Authorization should be not granted.")
    }
    
    func test_getCurrentAuthorizationSetting_forEphemeral() async {
        mockNotificationCenter.mockSettings = NotificationSettings(authorizationStatus: .ephemeral)
        
        await sut.getCurrentAuthorizationSetting()
        
        XCTAssertFalse(sut.authorizationGranted, "Authorization should be not granted.")
    }
    
    func test_goToQuotesInSettingsApp_whenCanOpenURLIsTrue() {
        mockApplication.openCalled = true
        
        sut.goToQuotesInSettingsApp()
        
        XCTAssertTrue(mockApplication.openCalled, "UIApplication open method should be called.")
    }
    
    func test_goToQuotesInSettingsApp_whenCanOpenURLIsFalse() {
        mockApplication.canOpenURLValue = false
        
        sut.goToQuotesInSettingsApp()
        
        XCTAssertFalse(mockApplication.openCalled, "UIApplication open method should not be called.")
    }
    
    func test_scheduleNotificationSuccess() async throws {
        try await sut.scheduleUserChosenNotificationTime(userChosenNotificationHour: 9, userChosenNotificationMinute: 30)
        
        XCTAssertTrue(mockNotificationCenter.removeAllPendingNotificationRequestsCalled, "UNUserNotificationCenter removeAllPendingNotificationRequests method should be called.")
        XCTAssertTrue(mockNotificationCenter.addCalled, "UNUserNotificationCenter add method should be called.")
        XCTAssertEqual(sut.notificationTime, "09:30", "Notification time should be set correctly.")
    }
    
    func test_scheduleNotificationFailure() async {
        mockNotificationCenter.shouldThrowAddError = true
        
        do {
            try await sut.scheduleUserChosenNotificationTime(userChosenNotificationHour: 9, userChosenNotificationMinute: 30)
            XCTFail("Expected to throw")
        } catch {
            XCTAssertTrue(sut.hasError, "Error should be set to true.")
            XCTAssertEqual(sut.notificationError, .failedToSetNotificationTime, "`NotificationError` should be .failedToSetNotificationTime.")
        }
    }
}
