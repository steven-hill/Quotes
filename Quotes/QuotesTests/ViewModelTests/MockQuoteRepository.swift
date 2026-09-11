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
    private(set) var addCallCount: Int = 0
    private(set) var updateReflectionCallCount: Int = 0
    private(set) var deleteCallCount: Int = 0
    
    func loadAllQuotes() throws -> [Quote] {
        loadAllQuotesCallCount += 1
        if fetchSucceeded {
            return stubbedQuotes
        }
        let error = NSError(domain: "FetchError", code: 1, userInfo: nil)
        throw RepositoryError.fetchFailed(underlying: error)
    }
    
    func add(_ quote: Quote) throws {
        addCallCount += 1
    }
    
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws {
        updateReflectionCallCount += 1
    }
    
    func delete(_ quoteID: UUID) throws {
        deleteCallCount += 1
    }
}
