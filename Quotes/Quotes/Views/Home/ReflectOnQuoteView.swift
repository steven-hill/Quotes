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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var userThoughts: String = ""
    @State private var showConfirmationDialog = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var viewModel: ReflectOnQuoteViewModel
    
    // MARK: - Constants
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - Action
    let successfulSave: () -> Void
    
    // MARK: - Dependency
    private let quoteRepository: QuoteRepository
    
    // MARK: - Initialisation
    init(
        quoteRepository: QuoteRepository,
        successfulSave: @escaping () -> Void
    ) {
        self.quoteRepository = quoteRepository
        _viewModel = State(initialValue: ReflectOnQuoteViewModel(repository: quoteRepository))
        self.successfulSave = successfulSave
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QuoteContentAndAuthorView(quoteContent: quoteContent, quoteAuthor: quoteAuthor)
                        .dynamicTypeSizeModifier()
                } else {
                    QuoteContentAndAuthorView(quoteContent: quoteContent, quoteAuthor: quoteAuthor)
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
                            text: quoteContent,
                            author: quoteAuthor,
                            date: Date(),
                            reflection: userThoughts
                        )
                        viewModel.saveQuoteWithReflection(quote: quote)
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
    
    // MARK: - Save method
    private func saveNewQuoteWithReflection() {
        if userThoughts.isEmpty {
            showConfirmationDialog.toggle()
        } else {
            let quoteToSave = SavedQuote(context: managedObjectContext)
            quoteToSave.quoteContent = quoteContent
            quoteToSave.quoteAuthor = quoteAuthor
            quoteToSave.reflection = userThoughts
            do {
                try PersistenceController.shared.save()
                dismiss()
                successfulSave()
            } catch {
                showAlert.toggle()
                alertMessage = PersistenceController.shared.persistenceError.localizedDescription
            }
        }
    }
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    ReflectOnQuoteView(
        quoteRepository: appContainer.quoteRepository,
        successfulSave: {}
    )
}
