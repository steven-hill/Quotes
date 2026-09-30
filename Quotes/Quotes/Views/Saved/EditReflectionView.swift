//
//  EditReflectionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct EditReflectionView: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var editReflectionVM: EditReflectionViewModel
    @State var userThoughts: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Dependencies
    private let savedQuote: Quote
    private let quoteRepository: QuoteRepository
    private let successfulSave: () -> Void
    private let refreshList: () -> Void
    
    // MARK: - Initialisation
    init(
        savedQuote: Quote,
        quoteRepository: QuoteRepository,
        userThoughts: String,
        successfulSave: @escaping () -> Void,
        refreshList: @escaping () -> Void
    ) {
        self.savedQuote = savedQuote
        self.quoteRepository = quoteRepository
        _editReflectionVM = State(initialValue: EditReflectionViewModel(repository: quoteRepository))
        self.userThoughts = userThoughts
        self.successfulSave = successfulSave
        self.refreshList = refreshList
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QuoteContentAndAuthorView(
                        quoteContent: savedQuote.text,
                        quoteAuthor: savedQuote.author
                    )
                    .minimumScaleFactor(0.75)
                    .dynamicTypeSizeModifier()
                } else {
                    QuoteContentAndAuthorView(
                        quoteContent: savedQuote.text,
                        quoteAuthor: savedQuote.author
                    )
                }
                ReflectionEditor(
                    text: $userThoughts,
                    accessibilityLabel: "Edit your reflection."
                )
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit reflection")
            .purpleGradientBackgroundModifier()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { CancelButton(accessibilityLabel: "Cancel editing and don't save.") }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        editReflectionVM.updateReflection(
                            quote: savedQuote,
                            reflection: userThoughts
                        )
                        if editReflectionVM.isReflectionUpdated {
                            successfulSave()
                            dismiss()
                            refreshList()
                        }
                    }
                    .alert(item: $editReflectionVM.reflectionAlert) { alert in
                        switch alert {
                        case .updateError(let message):
                            Alert(
                                title: Text("Update Error"),
                                message: Text(message),
                                dismissButton: .default(Text("Ok"))
                            )
                        }
                    }
                    .confirmationDialog(
                        "Tapped save button without text in editor.",
                        isPresented: $editReflectionVM.showConfirmationDialog,
                        titleVisibility: .hidden
                    ) {
                        Button("Discard reflection", role: .destructive) { dismiss() }
                        Button("Continue reflecting") {}
                    } message: {
                        Text("This quote won't be saved without a reflection.")
                    }
                }
            }
        }
    }
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    EditReflectionView(
        savedQuote: Quote.sample[0],
        quoteRepository: appContainer.quoteRepository,
        userThoughts: "User's reflection goes here.",
        successfulSave: {},
        refreshList: {}
    )
}
