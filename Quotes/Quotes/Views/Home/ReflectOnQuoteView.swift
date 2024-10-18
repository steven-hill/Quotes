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
                Text(quoteContent + " - " + quoteAuthor)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(quoteContent). End quote. \(quoteAuthor)")
                ZStack {
                    TextEditor(text: $userThoughts)
                        .accessibilityLabel("Enter your reflection.")
                        .foregroundStyle(.primary)
                        .background(.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.primary, lineWidth: 2)
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Reflection")
                        .scrollDismissesKeyboard(.immediately)
                    
                    if userThoughts.isEmpty {
                        VStack {
                            HStack {
                                Text("What are your thoughts on today's quote?")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 10)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel reflection and don't save.")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
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
                    .alert("Error saving", isPresented: $showAlert, presenting: alertMessage) { detail in
                        Button("Ok") {}
                    } message: { detail in
                        Text(alertMessage)
                    }
                }
            }
        }
    }
}

#Preview {
    ReflectOnQuoteView(userThoughts: "", quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
