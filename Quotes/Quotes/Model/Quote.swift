//
//  Quote.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

/// Model for displaying data in the UI.
/// A quote's `id` is nil until the quote is persisted locally, and `PersistedQuote` provides the `id` via mapping.
struct Quote {
    let id: UUID?
    let text: String
    let author: String
    let date: Date
    var reflection: String = ""
}

extension Quote {
    static let sample = [
        Quote(
            id: nil,
            text: "First text",
            author: "An author",
            date: Date()
        ),
        Quote(
            id: nil,
            text: "Second text",
            author: "Writer",
            date: Date()
        ),
        Quote(
            id: nil,
            text: "Third",
            author: "Scribe",
            date: Date()
        )
    ]
}
