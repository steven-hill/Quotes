//
//  QuoteOfTheDayView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct QuoteOfTheDayView: View {
    
    // MARK: - Environment
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // MARK: - State object
    @StateObject var quoteOfTheDayVM = QuoteViewModel(quoteService: QuoteService(cacheManager: CacheManager()))
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                content
                    .padding(.top, 30)
                    .navigationTitle("Home")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .pinkBluePurpleBackgroundModifier()
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
    
    // MARK: - UI components
    @ViewBuilder
    private var content: some View {
        switch quoteOfTheDayVM.state {
        case .success(_):
            quoteCardAndButtons
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        default:
            ContentUnavailableView("A quote will appear here.", systemImage: "quote.bubble")
        }
    }
    
    private var quoteCardAndButtons: some View {
        VStack {
            QuoteCardView(quoteContent: quoteOfTheDayVM.quoteContent, quoteAuthor: quoteOfTheDayVM.quoteAuthor)
            if verticalSizeClass == .compact {
                HStack {
                    buttons
                }
            } else {
                VStack {
                    buttons
                }
            }
        }
    }
    
    private var buttons: some View {
        Group {
            ReflectOnThisQuoteButton(quoteContent: quoteOfTheDayVM.quoteContent, quoteAuthor: quoteOfTheDayVM.quoteAuthor)
            QuoteOfTheDayShareLink(item: quoteOfTheDayVM.quoteToShare)
        }
    }
}

#Preview {
    QuoteOfTheDayView(quoteOfTheDayVM: QuoteViewModel(quoteService: QuoteService(cacheManager: CacheManager())))
}
