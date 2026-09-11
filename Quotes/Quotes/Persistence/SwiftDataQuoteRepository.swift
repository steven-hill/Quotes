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
    
    //MARK: - Methods
    func loadAllQuotes() throws -> [Quote] {
        let descriptor = FetchDescriptor<PersistedQuote>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor).map { persistedQuote in
                Quote(
                    id: persistedQuote.id,
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
    
    func updateReflection(
        for quoteID: UUID,
        reflection: String
    ) throws {
        let descriptor = FetchDescriptor<PersistedQuote>(
            predicate: #Predicate {
                $0.id == quoteID
            }
        )
        do {
            guard let persistedQuote = try context.fetch(descriptor).first else {
                throw RepositoryError.quoteNotFound
            }
            persistedQuote.reflection = reflection
            try context.save()
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.updateFailed(underlying: error)
        }
    }
}
