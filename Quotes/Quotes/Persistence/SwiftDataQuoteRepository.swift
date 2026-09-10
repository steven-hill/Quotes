//
//  SwiftDataQuoteRepository.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
import SwiftData

final class SwiftDataQuoteRepository: QuoteRepository {
    
    //MARK: - Dependency
    private let context: ModelContext
    
    //MARK: - Initialisation
    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }
    
    //MARK: - Method
    func loadAllQuotes() throws -> [Quote] {
        let descriptor = FetchDescriptor<PersistedQuote>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor).map { persistedQuote in
                Quote(
                    text: persistedQuote.text,
                    author: persistedQuote.author,
                    date: persistedQuote.date,
                    reflection: persistedQuote.reflection
                )
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
}
