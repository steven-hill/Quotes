//
//  PersistedQuote.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
import SwiftData

@Model
final class PersistedQuote {
    private(set) var id: UUID
    var text: String
    var author: String
    var date: Date
    var reflection: String
    
    init(
        id: UUID = UUID(),
        text: String,
        author: String,
        date: Date,
        reflection: String
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.date = date
        self.reflection = reflection
    }
}
