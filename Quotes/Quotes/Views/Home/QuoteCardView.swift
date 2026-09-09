//
//  QuoteCardView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct QuoteCardView: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var isPresented = false
    
    // MARK: - Constants
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - Body
    var body: some View {
        VStack {
            if isPresented {
                quoteContentView
                    .transition(.move(edge: .top))
                authorView
                    .transition(.move(edge: .bottom))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(quoteContent). End quote. \(quoteAuthor)")
        .padding()
        .cardBackgroundModifier()
        .padding()
        .onAppear {
            isPresented.toggle()
        }
        .animation(.smooth(duration: 1), value: isPresented)
        .onDisappear {
            isPresented = false
        }
    }
    
    // MARK: - UI components
    private var quoteContentView: some View {
        VStack {
            HStack {
                Image(systemName: "quote.opening")
                Spacer()
            }
            
            Text(quoteContent)
                .font(.title)
                .padding(.horizontal)
            
            HStack {
                Spacer()
                Image(systemName: "quote.closing")
            }
            .padding(.bottom)
        }
    }
    
    private var authorView: some View {
        Text(quoteAuthor)
            .font(.title2)
    }
}

#Preview {
    QuoteCardView(quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
