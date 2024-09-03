//
//  CacheManager.swift
//  Quotes
//
//  Created by Steven Hill on 02/09/2024.
//

import Foundation

protocol CacheProtocol {
    func save(key: String, value: Data)
    func retrieve(key: String) -> Data?
}

final class CacheManager: CacheProtocol {
    private let cache = NSCache<NSString, NSData>()
    
    func save(key: String, value: Data) {
        cache.setObject(value as NSData, forKey: key as NSString)
    }
    
    func retrieve(key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }
}
