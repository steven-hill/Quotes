//
//  MockUserDefaults.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/12/2024.
//

import Foundation
@testable import Quotes

class MockUserDefaults: UserDefaultsProviding {
    private var storedValues: [String: Any] = [:]
    
    func integer(forKey defaultName: String) -> Int {
        return storedValues[defaultName] as? Int ?? 0
    }

    func set(_ value: Int, forKey defaultName: String) {
        storedValues[defaultName] = value
    }
}
