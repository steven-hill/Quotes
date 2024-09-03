//
//  MockCacheManager.swift
//  QuotesTests
//
//  Created by Steven Hill on 03/09/2024.
//

import Foundation
@testable import Quotes

class MockCacheManager: CacheProtocol {
    var cachedItems: [String: Data] = [:]
    
    func save(key: String, value: Data) {
        cachedItems[key] = value
    }
    
    func retrieve(key: String) -> Data? {
        cachedItems[key]
    }   
}
