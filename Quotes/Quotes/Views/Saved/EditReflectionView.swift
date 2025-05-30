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
    
    // MARK: - Constants
    let savedQuote: SavedQuote
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - State
    @State var userThoughts: String
    @State private var showConfirmationDialog = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Action
    let successfulSave: () -> Void
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    QuoteContentAndAuthorView(quoteContent: quoteContent, quoteAuthor: quoteAuthor)
                        .minimumScaleFactor(0.75)
                        .dynamicTypeSizeModifier()
                } else {
                    QuoteContentAndAuthorView(quoteContent: quoteContent, quoteAuthor: quoteAuthor)
                }
                ReflectionEditor(text: $userThoughts, accessibilityLabel: "Edit your reflection.")
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit reflection")
            .purpleGradientBackgroundModifier()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { CancelButton(accessibilityLabel: "Cancel editing and don't save.") }
                ToolbarItem(placement: .topBarTrailing) { SaveButton(saveAction: saveEditedReflection, showConfirmationDialog: $showConfirmationDialog, confirmationDialogActions: {
                    [
                        IdentifiableButton(button: Button(role: .destructive, action: { dismiss() }, label: { Text("Discard changes") })),
                        IdentifiableButton(button: Button(role: .cancel, action: {}, label: { Text("Continue editing") }))
                    ]
                }, confirmationDialogMessage: "Please add some text so your reflection can be updated.", showAlert: $showAlert, alertMessage: alertMessage) }
            }
        }
    }
    
    // MARK: - Save method
    private func saveEditedReflection() {
        if userThoughts.isEmpty {
            showConfirmationDialog.toggle()
        } else {
            savedQuote.reflection = userThoughts
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
    let previewSavedQuote = SavedQuote()
    EditReflectionView(
        savedQuote: previewSavedQuote,
        quoteContent: "Never allow someone to be your priority while allowing yourself to be their option.",
        quoteAuthor: "Mark Twain",
        userThoughts: "User's reflection goes here.", successfulSave: {})
}
