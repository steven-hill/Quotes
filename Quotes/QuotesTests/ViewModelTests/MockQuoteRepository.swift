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
        throw RepositoryError.fetchFailed
    }
    
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws {
        
    }
}
