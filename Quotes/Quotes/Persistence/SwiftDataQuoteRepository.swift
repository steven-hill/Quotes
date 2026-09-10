//
//  SwiftDataQuoteRepository.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

final class SwiftDataQuoteRepository: QuoteRepository {
    func loadAllQuotes() throws -> [Quote] {
        [Quote.sample]
    }
}
