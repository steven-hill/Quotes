//
//  AppearanceManagerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/12/2024.
//

import XCTest
@testable import Quotes

@MainActor
final class AppearanceManagerTests: XCTestCase {

    private var mockUD: UserDefaults!
    private var suiteName: String!
    private var sut: AppearanceManager!
    
    override func setUp() async throws {
        try await super.setUp()
        suiteName = "AppearanceManagerTests.\(UUID().uuidString)"
        mockUD = UserDefaults(suiteName: suiteName)
        sut = AppearanceManager(store: mockUD)
    }
    
    override func tearDown() async throws {
        mockUD.removePersistentDomain(forName: suiteName)
        sut = nil
        try await super.tearDown()
    }
    
    func test_appearanceManager_onInit_selectedAppearance_isSystem() {
        XCTAssertEqual(sut.selectedAppearance, .system, "Should be system.")
    }
    
    func test_appearanceManager_setAppearance_toLight_setsSelectedAppearanceToLight() {
        sut.setAppearance(.light)
        
        XCTAssertEqual(sut.selectedAppearance, .light, "Should be light.")
        XCTAssertEqual(
            mockUD.string(forKey: "selectedAppearance"),
            Appearance.light.rawValue, "Should be `light`."
        )
    }
    
    func test_appearanceManager_setAppearance_toDark_setsSelectedAppearanceToDark() {
        sut.setAppearance(.dark)

        XCTAssertEqual(sut.selectedAppearance, .dark, "Should be dark.")
        XCTAssertEqual(
            mockUD.string(forKey: "selectedAppearance"),
            Appearance.dark.rawValue, "Should be `dark`."
        )
    }
    
    func test_appearanceManager_setAppearance_toSystem_setsSelectedAppearanceToSystem() {
        sut.setAppearance(.system)

        XCTAssertEqual(sut.selectedAppearance, .system, "Should be system.")
        XCTAssertEqual(
            mockUD.string(forKey: "selectedAppearance"),
            Appearance.system.rawValue, "Should be `system`."
        )
    }
}
