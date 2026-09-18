//
//  ReflectOnQuoteView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct ReflectOnQuoteView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var userThoughts: String = ""
    @State private var viewModel: ReflectOnQuoteViewModel
    
    // MARK: - Property
    let quote: Quote
    
    // MARK: - Action
    let successfulSave: () -> Void
    
    // MARK: - Dependency
    private let quoteRepository: QuoteRepository
    
    // MARK: - Initialisation
    init(
        quote: Quote,
        quoteRepository: QuoteRepository,
        successfulSave: @escaping () -> Void
    ) {
        self.quote = quote
        self.quoteRepository = quoteRepository
        _viewModel = State(initialValue: ReflectOnQuoteViewModel(repository: quoteRepository))
        self.successfulSave = successfulSave
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QuoteContentAndAuthorView(
                        quoteContent: quote.text,
                        quoteAuthor: quote.author
                    )
                        .dynamicTypeSizeModifier()
                } else {
                    QuoteContentAndAuthorView(
                        quoteContent: quote.text,
                        quoteAuthor: quote.author
                    )
                }
                ReflectionEditor(text: $userThoughts, accessibilityLabel: "Enter your reflection.")
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Reflection")
            .purpleGradientBackgroundModifier()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CancelButton(accessibilityLabel: "Cancel reflection and don't save.")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        let quote = Quote(
                            id: nil,
                            text: quote.text,
                            author: quote.author,
                            date: Date(),
                            reflection: userThoughts
                        )
                        viewModel.saveQuoteWithReflection(
                            quote: quote,
                            reflection: userThoughts
                        )
                        if viewModel.isQuoteSaved {
                            successfulSave()
                            dismiss()
                        }
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .confirmationDialog(
                        "Tapped save button without text in editor.",
                        isPresented: $viewModel.showConfirmationDialog,
                        titleVisibility: .hidden
                    ) {
                        Button("Discard reflection", role: .destructive) { dismiss() }
                        Button("Continue reflecting") {}
                    } message: {
                        Text("This quote won't be saved if no reflection is added.")
                    }
                    .alert("Save failed", isPresented: $viewModel.hasError, presenting: $viewModel.errorMessage) { detail in
                        Button("Ok") {}
                    } message: { detail in
                        Text("\(detail) Please try again.")
                    }
                }
            }
        }
    }
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    ReflectOnQuoteView(
        quote: Quote.sample[0],
        quoteRepository: appContainer.quoteRepository,
        successfulSave: {}
    )
}
