//
//  QuoteRepository.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

protocol QuoteRepository {
    /// Passing nil returns all `PersistedQuote`; passing a string filters them using the query.
    func loadAllQuotes(matching query: String?) throws -> [Quote]
    func add(_ quote: Quote) throws
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws
    func delete(_ quoteID: UUID) throws
}
