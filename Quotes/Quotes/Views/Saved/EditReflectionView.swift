//
//  EditReflectionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct EditReflectionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    let savedQuote: SavedQuote
    let quoteContent: String
    let quoteAuthor: String
    @State var userThoughts: String
    @State private var showConfirmationDialog = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(quoteContent + " - " + quoteAuthor)
                ZStack {
                    TextEditor(text: $userThoughts)
                        .foregroundStyle(.primary)
                        .background(.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.primary, lineWidth: 2)
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("Edit reflection")
                        .scrollDismissesKeyboard(.immediately)
                    
                    if userThoughts.isEmpty {
                        VStack {
                            HStack {
                                Text("What are your thoughts on this quote?")
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
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
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
                    .buttonStyle(.bordered)
                    .confirmationDialog("Tapped save button without any text.", isPresented: $showConfirmationDialog, titleVisibility: .hidden, actions: {
                        Button(role: .cancel, action: {}, label: {
                            Text("Keep reflecting")
                        })
                    }, message: {
                        Text("Please add some text so your reflection can be updated.")
                    })
                    .alert("Error", isPresented: $showAlert, presenting: alertMessage) { detail in
                        Button("Ok") {}
                    } message: { detail in
                        Text("\(alertMessage). Please try again.")
                    }
                }
            }
        }
    }
}
