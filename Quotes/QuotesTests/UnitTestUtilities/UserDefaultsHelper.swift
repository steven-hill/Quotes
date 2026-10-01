//
//  UserDefaultsHelper.swift
//  QuotesTests
//
//  Created by Steven Hill on 01/10/2026.
//

import Foundation

struct UserDefaultsHelper {
    static func makeUserDefaults(for testFile: String) -> UserDefaults {
        let suiteName = "\(testFile).\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
