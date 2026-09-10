//
//  SwiftDataQuoteRepository.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
import SwiftData

final class SwiftDataQuoteRepository: QuoteRepository {
    private let context: ModelContext
    
    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }
    
    func loadAllQuotes() throws -> [Quote] {
        let descriptor = FetchDescriptor<PersistedQuote>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return try context.fetch(descriptor).map { persistedQuote in
            Quote(
                text: persistedQuote.text,
                author: persistedQuote.author,
                date: persistedQuote.date
            )
        }
    }
}
