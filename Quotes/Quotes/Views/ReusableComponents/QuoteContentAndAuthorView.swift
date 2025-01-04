//
//  QuoteContentAndAuthorView.swift
//  Quotes
//
//  Created by Steven Hill on 04/01/2025.
//

import SwiftUI

struct QuoteContentAndAuthorView: View {
    let quoteContent: String
    let quoteAuthor: String
    
    var body: some View {
        Text(quoteContent + " - " + quoteAuthor)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(quoteContent). End quote. \(quoteAuthor)")
    }
}

#Preview {
    QuoteContentAndAuthorView(quoteContent: "Never allow someone to be your priority while allowing yourself to be their option.", quoteAuthor: "Mark Twain")
}
