//
//  MockQuoteRepository.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
@testable import Quotes

final class MockQuoteRepository: QuoteRepository {
    var stubbedQuotes: [Quote] = []
    var fetchSucceeded: Bool = true
    private(set) var loadAllQuotesCallCount: Int = 0
    
    func loadAllQuotes() throws -> [Quote] {
        loadAllQuotesCallCount += 1
        if fetchSucceeded {
            return stubbedQuotes
        }
        let error = NSError(domain: "FetchError", code: 1, userInfo: nil)
        throw RepositoryError.fetchFailed(underlying: error)
    }
    
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws {
        
    }
}
