//
//  PersistenceHelper.swift
//  QuotesTests
//
//  Created by Steven Hill on 11/09/2026.
//

import Foundation
@testable import Quotes

struct PersistenceHelper {
    @MainActor static func makePersistedQuote(
        using quote: Quote,
        reflection: String
    ) -> PersistedQuote {
        return PersistedQuote(
            text: quote.text,
            author: quote.author,
            date: quote.date,
            reflection: reflection
        )
    }
    
    static func mapToQuote(_ persistedQuote: PersistedQuote) -> Quote {
        Quote(
            id: persistedQuote.id,
            text: persistedQuote.text,
            author: persistedQuote.author,
            date: persistedQuote.date,
            reflection: persistedQuote.reflection
        )
    }
}
