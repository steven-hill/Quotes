//
//  CacheManagerTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 03/09/2024.
//

import XCTest
@testable import Quotes

final class CacheManagerTests: XCTestCase {
    
    var sut: MockCacheManager!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = MockCacheManager()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }
    
    func test_cacheManager_canSaveAndRetrieve() {
        let key = "testKey"
        let value = makeData()
        
        sut.save(key: key, value: value)
        XCTAssertEqual(sut.cachedItems.count, 1, "Should be one item in the cache.")
        
        let retrievedValue = sut.retrieve(key: key)
        XCTAssertEqual(retrievedValue, value, "Retrieved value should equal saved value.")
    }
    
    func test_cacheManager_cantRetrieveNonExistentKey() {
        let retrievedValue = sut.retrieve(key: "nonExistentKey")
        
        XCTAssertNil(retrievedValue, "Retrieving a non-existent key should return nil.")
    }
    
    // MARK: - Helper
    
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    private func makeData() -> Data {
        guard let path = bundle.url(forResource: "QuoteResponse", withExtension: "json") else {
            fatalError("Failed to load the mock quote response JSON file.")
        }
        
        do {
            let data = try Data(contentsOf: path)
            return data
        } catch {
            print("\(error)")
            fatalError("Making data failed.")
        }
    }
}
