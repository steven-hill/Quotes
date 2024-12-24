//
//  AppearanceManagerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/12/2024.
//

import XCTest
@testable import Quotes

final class AppearanceManagerTests: XCTestCase {

    private var mockUserDefaults: MockUserDefaults!
    private var mockWindowProvider: MockWindowProvider!
    private var sut: AppearanceManager!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        mockWindowProvider = MockWindowProvider()
        sut = AppearanceManager(userDefaults: mockUserDefaults, windowProvider: mockWindowProvider)
    }
    
    override func tearDown() {
        super.tearDown()
        mockUserDefaults = nil
        mockWindowProvider = nil
        sut = nil
    }
    
    func test_defaultAppearance_IsSystemWhenAppearanceManagerIsInitialized() {
        XCTAssertEqual(sut.selectedAppearance, .unspecified, "Default appearance should be system.")
    }
    
    func test_settingAppearanceToLight_setsDisplayModeToLight() {
        sut.setAppearance(.light)
        sut.overrideDisplayMode()
        XCTAssertEqual(mockWindowProvider.mockWindow.overrideUserInterfaceStyle, .light, "Should be light.")
    }
    
    func test_settingAppearanceToDark_setsDisplayModeToDark() {
        sut.setAppearance(.dark)
        sut.overrideDisplayMode()
        XCTAssertEqual(mockWindowProvider.mockWindow.overrideUserInterfaceStyle, .dark, "Should be dark.")
    }
    
    func test_settingAppearanceToSystem_setsDisplayModeToSystem() {
        sut.setAppearance(.unspecified)
        sut.overrideDisplayMode()
        XCTAssertEqual(mockWindowProvider.mockWindow.overrideUserInterfaceStyle, .unspecified, "Should be system.")
    }
    
    func test_settingAppearanceToLight_setsUserDefaultsAppearanceToLight() {
        sut.setAppearance(.light)
        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.light.rawValue, "User defaults appearance should be light.")
    }
    
    func test_settingAppearanceToDark_setsUserDefaultsAppearanceToDark() {
        sut.setAppearance(.dark)
        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.dark.rawValue, "User defaults appearance should be dark.")
    }
    
    func test_settingAppearanceToSystem_setsUserDefaultsAppearanceToUnspecified() {
        sut.setAppearance(.unspecified)
        XCTAssertEqual(mockUserDefaults.integer(forKey: "selectedAppearance"), Appearance.unspecified.rawValue, "User defaults appearance should be system.")
    }
}
