//
//  QuoteOfTheDayShareLink.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct QuoteOfTheDayShareLink: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: String
    
    var body: some View {
        ShareLink("Share", item: item)
            .tint(.primary)
            .padding(.all)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.buttonWidth : .infinity)
            .foregroundStyle(.gray)
            .bold()
            .padding()
    }
}

#Preview {
    QuoteOfTheDayShareLink(item: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him. - Confucius")
}
