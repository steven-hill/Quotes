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
    
    init(
        text: String,
        author: String,
        date: Date
    ) {
        self.text = text
        self.author = author
        self.date = date
    }
}
