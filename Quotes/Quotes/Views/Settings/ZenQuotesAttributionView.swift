//
//  ZenQuotesAttributionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct ZenQuotesAttributionView: View {
    var body: some View {
        GroupBox {
            HStack {
                Link("Quotes provided by ZenQuotes API", destination: URL(string: "https://zenquotes.io/")!)
                    .font(.headline)
                    .foregroundStyle(.link)
            }
            .padding(.top, 5)
        } label: {
            Label("Attribution", systemImage: "quote.bubble")
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.viewWidth : .infinity)
    }
}

#Preview {
    ZenQuotesAttributionView()
}
