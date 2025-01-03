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
    
    // MARK: - State
    @State var userThoughts: String = ""
    @State private var showConfirmationDialog = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Constants
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                quoteContentAndAuthorView
                ReflectionEditor(text: $userThoughts, accessibilityLabel: "Enter your reflection.")
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Reflection")
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
        .accessibilityLabel("Cancel reflection and don't save.")
    }
    
    private var saveButton: some View {
        Button("Save") {
            saveReflection()
        }
        .accessibilityLabel("Save quote and reflection.")
        .buttonStyle(.bordered)
        .confirmationDialog("Tapped save button without entering text.", isPresented: $showConfirmationDialog, titleVisibility: .hidden, actions: {
            Button(role: .destructive, action: {
                dismiss()
            }, label: {
                Text("Delete reflection")
            })
            Button(role: .cancel, action: {}, label: {
                Text("Keep reflecting")
            })
        }, message: {
            Text("This quote won't be saved if no reflection is added.")
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
            let quoteToSave = SavedQuote(context: managedObjectContext)
            quoteToSave.quoteContent = quoteContent
            quoteToSave.quoteAuthor = quoteAuthor
            quoteToSave.reflection = userThoughts
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

#Preview {
    ReflectOnQuoteView(userThoughts: "", quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
