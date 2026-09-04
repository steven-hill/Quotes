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
    
    func test_appearanceManager_onInit_ifLightWasPreviouslySaved_loadsThatValue() {
        mockUD.set(
            Appearance.light.rawValue,
            forKey: "selectedAppearance"
        )

        /// Initialise a different sut so it can read from the already persisted value.
        let secondarySut = AppearanceManager(store: mockUD)
        
        XCTAssertEqual(secondarySut.selectedAppearance, .light, "Should be the saved value.")
    }
    
    func test_appearanceManager_onInit_ifDarkWasPreviouslySaved_loadsThatValue() {
        mockUD.set(
            Appearance.dark.rawValue,
            forKey: "selectedAppearance"
        )

        /// Initialise a different sut so it can read from the already persisted value.
        let secondarySut = AppearanceManager(store: mockUD)
        
        XCTAssertEqual(secondarySut.selectedAppearance, .dark, "Should be the saved value.")
    }
}
