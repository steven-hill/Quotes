//
//  ZenQuotesAttributionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct ZenQuotesAttributionView: View {
    var body: some View {
        Text(createAttributedString())
            .font(.title3)
    }
    
    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString("Inspirational quotes provided by ")
        var linkPart = AttributedString("ZenQuotes API")
        linkPart.link = URL(string: "https://www.zenquotes.io/")
        linkPart.foregroundColor = .link
        
        attributedString += linkPart
        return attributedString
    }
}

#Preview {
    ZenQuotesAttributionView()
}
