//
//  QuoteRepository.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

protocol QuoteRepository {
    func loadAllQuotes() throws -> [Quote]
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws
    func delete(_ quoteID: UUID) throws
}
