//
//  MockQuoteRepository.swift
//  QuotesTests
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
@testable import Quotes

final class MockQuoteRepository: QuoteRepository {
    func loadAllQuotes() throws -> [Quote] {
        [Quote.sample]
    }
}
