//
//  MockUserDefaults.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/12/2024.
//

import Foundation

class MockUserDefaults: UserDefaults {
    var storedValues: [String: Any] = [:]

    override func set(_ value: Int, forKey defaultName: String) {
        storedValues[defaultName] = value
    }

    override func integer(forKey defaultName: String) -> Int {
        return storedValues[defaultName] as? Int ?? 0
    }
}
