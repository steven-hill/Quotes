//
//  MockApplication.swift
//  QuotesTests
//
//  Created by Steven Hill on 30/04/2025.
//

import XCTest
@testable import Quotes

final class MockApplication: ApplicationProtocol {
    var canOpenURLValue = true
    var openCalled = false

    func canOpenURL(_ url: URL) -> Bool {
        return canOpenURLValue
    }

    func open(_ url: URL) {
        openCalled = true
    }
}
