//
//  SavedCardView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI
import UIKit

struct SavedCardView: View {
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var isPopoverPresented = false
    @State private var isEditReflectionSheetPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteQuoteAlert: Bool = false
    
    // MARK: - Constants
    let deleteQuoteAlertMessage = "This action can't be undone."
    let savedQuote: SavedQuote
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            menuButton
                            .sheet(isPresented: $isEditReflectionSheetPresented) {
                                EditReflectionView(savedQuote: savedQuote, quoteContent: savedQuote.quoteContent ?? "Content unavailable", quoteAuthor: savedQuote.quoteAuthor ?? "Author name unavailable", userThoughts: savedQuote.reflection ?? "Reflection unavailable")
                                    .presentationDragIndicator(.visible)
                            }
                            .alert("Error", isPresented: $showAlert, presenting: alertMessage) { detail in
                                Button("Please try again") {}
                            } message: { detail in
                                Text(alertMessage)
                            }
                            .alert("Are you sure?", isPresented: $showDeleteQuoteAlert, presenting: deleteQuoteAlertMessage) { detail in
                                Button("Delete", role: .destructive) {
                                    do {
                                        try PersistenceController.shared.delete(savedQuote: savedQuote)
                                    } catch {
                                        showAlert.toggle()
                                        alertMessage = PersistenceController.shared.persistenceError.localizedDescription
                                    }
                                }
                            } message: { detail in
                                Text(deleteQuoteAlertMessage)
                            }
                        }
                    }
                }
                HStack {
                    Image(systemName: "quote.opening")
                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Start quote")
                Text(savedQuote.quoteContent ?? "Quote unavailable")
                    .minimumScaleFactor(0.5)
                    .padding([.leading, .trailing])
                    .font(.callout)
                HStack {
                    Spacer()
                    Image(systemName: "quote.closing")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("End quote")
                Text(savedQuote.quoteAuthor ?? "Author name unavailable")
                    .font(.callout)
            }
            .padding()
            .background(cardBackground)
        }
    }
    
    // MARK: - UI Components
    private var menuButton: some View {
        Menu {
            Button {
                isPopoverPresented.toggle()
                presentActivityController()
            } label: {
                Label("Share this quote", systemImage: "square.and.arrow.up")
            }
            Button("Edit your reflection", systemImage: "square.and.pencil") {
                isEditReflectionSheetPresented.toggle()
            }
            Button(role: .destructive) {
                showDeleteQuoteAlert.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Label("", systemImage: "ellipsis.circle.fill")
        }
        .accessibilityLabel("Menu")
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(colorScheme == .light ? .black.opacity(0.1) : .gray)
            .stroke(.primary, lineWidth: 2)
    }
}

extension SavedCardView {
    private func presentActivityController() {
        var quoteToShare: String = ""
        quoteToShare = "\(savedQuote.quoteContent ?? "Content unavailable")" + " - " + "\(savedQuote.quoteAuthor ?? "Author name unavailable")"
        let activityController = UIActivityViewController(activityItems: [quoteToShare], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            if UIDevice.current.userInterfaceIdiom == .pad {
                configurePopoverForIPad(activityController, in: window)
            }
            window.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
    
    private func configurePopoverForIPad(_ activityController: UIActivityViewController, in window: UIWindow) {
        activityController.popoverPresentationController?.sourceView = window
        activityController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
        activityController.popoverPresentationController?.permittedArrowDirections = []
    }
}
