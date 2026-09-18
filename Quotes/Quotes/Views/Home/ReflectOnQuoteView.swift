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
    
    // MARK: - Properties
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - Dependency
    private let quoteRepository: QuoteRepository
    
    // MARK: - Action
    let successfulSave: () -> Void
    
    // MARK: - Initialisation
    init(
        quoteContent: String,
        quoteAuthor: String,
        quoteRepository: QuoteRepository,
        successfulSave: @escaping () -> Void
    ) {
        self.quoteContent = quoteContent
        self.quoteAuthor = quoteAuthor
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
                        quoteContent: quoteContent,
                        quoteAuthor: quoteAuthor
                    )
                        .dynamicTypeSizeModifier()
                } else {
                    QuoteContentAndAuthorView(
                        quoteContent: quoteContent,
                        quoteAuthor: quoteAuthor
                    )
                }
                ReflectionEditor(
                    text: $userThoughts,
                    accessibilityLabel: "Enter your reflection."
                )
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
                    Button("Save") {
                        viewModel.saveQuoteWithReflection(
                            quoteContent: quoteContent,
                            quoteAuthor: quoteAuthor,
                            reflection: userThoughts
                        )
                        if viewModel.isQuoteSaved {
                            successfulSave()
                            dismiss()
                        }
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
        quoteContent: Quote.sample[0].text,
        quoteAuthor: Quote.sample[0].author,
        quoteRepository: appContainer.quoteRepository,
        successfulSave: {}
    )
}
