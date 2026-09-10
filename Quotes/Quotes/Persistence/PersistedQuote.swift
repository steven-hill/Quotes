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
    var text: String
    var author: String
    var date: Date
    var reflection: String
    
    init(
        text: String,
        author: String,
        date: Date,
        reflection: String
    ) {
        self.text = text
        self.author = author
        self.date = date
        self.reflection = reflection
    }
}
