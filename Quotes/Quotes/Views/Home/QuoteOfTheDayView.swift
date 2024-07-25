//
//  QuoteOfTheDayView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct QuoteOfTheDayView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject var quoteOfTheDayVM: QuoteViewModel
    
    var body: some View {
        NavigationStack {
            switch quoteOfTheDayVM.state {
            case .success(_):
                QuoteCardView(quoteContent: quoteOfTheDayVM.quoteContent, quoteAuthor: quoteOfTheDayVM.quoteAuthor)
                    .navigationTitle("Quote of the day")
                
                if verticalSizeClass == .compact {
                    HStack {
                        ReflectOnThisQuoteButton(quoteContent: quoteOfTheDayVM.quoteContent, quoteAuthor: quoteOfTheDayVM.quoteAuthor)
                        QuoteOfTheDayShareLink(item: quoteOfTheDayVM.quoteToShare)
                    }
                } else {
                    VStack {
                        ReflectOnThisQuoteButton(quoteContent: quoteOfTheDayVM.quoteContent, quoteAuthor: quoteOfTheDayVM.quoteAuthor)
                        QuoteOfTheDayShareLink(item: quoteOfTheDayVM.quoteToShare)
                    }
                }
            case .loading:
                ProgressView()
            default:
                ContentUnavailableView("A quote will appear here.", systemImage: "quote.bubble")
            }
        }
        .task {
            await quoteOfTheDayVM.getQuoteOfTheDay()
        }
        .alert("Error", isPresented: $quoteOfTheDayVM.hasError, presenting: quoteOfTheDayVM.state) { detail in
            Button("Retry") {
                Task {
                    await quoteOfTheDayVM.getQuoteOfTheDay()
                }
            }
        } message: { detail in
            if case let .failure(error) = detail {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    QuoteOfTheDayView(quoteOfTheDayVM: QuoteViewModel(quoteService: QuoteService()))
}
