//
//  EditReflectionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct EditReflectionView: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) var managedObjectContext
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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                quoteContentAndAuthorView
                ReflectionEditor(text: $userThoughts, accessibilityLabel: "Edit your reflection.")
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit reflection")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { cancelButton }
                ToolbarItem(placement: .topBarTrailing) { saveButton }
            }
        }
    }
    
    // MARK: - UI components
    private var quoteContentAndAuthorView: some View {
        Text(quoteContent + " - " + quoteAuthor)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(quoteContent). End quote. \(quoteAuthor)")
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .accessibilityLabel("Cancel editing and don't save.")
    }
    
    private var saveButton: some View {
        Button("Save") {
            saveReflection()
        }
        .accessibilityLabel("Save quote and reflection.")
        .buttonStyle(.bordered)
        .confirmationDialog("Tapped save button without any text.", isPresented: $showConfirmationDialog, titleVisibility: .hidden, actions: {
            Button(role: .cancel, action: {}, label: {
                Text("Keep reflecting")
            })
        }, message: {
            Text("Please add some text so your reflection can be updated.")
        })
        .alert("Save failed", isPresented: $showAlert, presenting: alertMessage) { _ in
            Button("Ok") {}
        } message: { _ in
            Text("\(alertMessage). Please try again.")
        }
    }
    
    // MARK: - Save method
    private func saveReflection() {
        if userThoughts.isEmpty {
            showConfirmationDialog.toggle()
        } else {
            savedQuote.reflection = userThoughts
            do {
                try PersistenceController.shared.save()
                dismiss()
            } catch {
                showAlert.toggle()
                alertMessage = PersistenceController.shared.persistenceError.localizedDescription
            }
        }
    }
}
