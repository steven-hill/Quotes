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
        XCTAssertEqual(sut.selectedAppearance, .system)
    }
    
    func test_appearanceManager_settingAppearanceToLight_setsSelectedAppearanceToLight() {
        sut.setAppearance(.light)
        
        XCTAssertEqual(sut.selectedAppearance, .light, "Should be light.")
        
        XCTAssertEqual(
            mockUD.string(forKey: "selectedAppearance"),
            Appearance.light.rawValue, "Should be light."
        )
    }
    
//    func test_settingAppearanceToDark_setsDisplayModeToDark() {
//        sut.setAppearance(.dark)
//        sut.overrideDisplayMode()
//        XCTAssertEqual(mockWindowProvider.mockWindow.overrideUserInterfaceStyle, .dark, "Should be dark.")
//    }
//    
//    func test_settingAppearanceToSystem_setsDisplayModeToSystem() {
//        sut.setAppearance(.unspecified)
//        sut.overrideDisplayMode()
//        XCTAssertEqual(mockWindowProvider.mockWindow.overrideUserInterfaceStyle, .unspecified, "Should be system.")
//    }
//    
//    func test_settingAppearanceToLight_setsUserDefaultsAppearanceToLight() {
//        sut.setAppearance(.light)
//        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.light.rawValue, "User defaults appearance should be light.")
//    }
//    
//    func test_settingAppearanceToDark_setsUserDefaultsAppearanceToDark() {
//        sut.setAppearance(.dark)
//        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.dark.rawValue, "User defaults appearance should be dark.")
//    }
//    
//    func test_settingAppearanceToSystem_setsUserDefaultsAppearanceToUnspecified() {
//        sut.setAppearance(.unspecified)
//        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.unspecified.rawValue, "User defaults appearance should be system.")
//    }
}
