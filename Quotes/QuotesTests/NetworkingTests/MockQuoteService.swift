//
//  MockQuoteService.swift
//  QuotesTests
//
//  Created by Steven Hill on 29/07/2024.
//

import Foundation
@testable import Quotes

final class MockQuoteService: QuoteServiceProtocol {
    
    var quoteResponse: QuoteServiceResult = []
    let mockURL = URL(string: "https://zenquotes.io/api/today")
    var shouldSucceed: Bool = true
    
    enum MockQuoteServiceError: Error, LocalizedError {
        case networkConnectionOffline
        case invalidURL
        case invalidStatusCode
        case invalidData
        case unknown(Error)
    }
    
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func readMockQuoteResponseJsonFile() -> QuoteServiceResult {
        guard let path = bundle.url(forResource: "QuoteResponse", withExtension: "json") else {
            fatalError("Failed to load the mock quote response JSON file.")
        }
        
        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(QuoteServiceResult.self, from: data)
            return decodedObject
        } catch {
            print("\(error)")
            fatalError("QuoteResponseJson decoding failed.")
        }
    }
    
    func fetchQuoteOfTheDay() async throws -> QuoteServiceResult {
        if shouldSucceed {
            quoteResponse = readMockQuoteResponseJsonFile()
            return quoteResponse
        } else {
            throw NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
    }
}

extension MockQuoteService.MockQuoteServiceError: Equatable {
    static func == (lhs: MockQuoteService.MockQuoteServiceError, rhs: MockQuoteService.MockQuoteServiceError) -> Bool {
        switch(lhs, rhs) {
        case(.networkConnectionOffline, .networkConnectionOffline):
            return true
        case(.invalidURL, .invalidURL):
            return true
        case(.invalidStatusCode, .invalidStatusCode):
            return true
        case(.invalidData, .invalidData):
            return true
        case(.unknown(let lhsType), .unknown(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
