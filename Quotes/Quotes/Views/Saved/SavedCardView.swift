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
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var isPopoverPresented = false
    @State private var isEditReflectionSheetPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteQuoteAlert = false
    @State private var saveIsSuccessful = false
    
    // MARK: - Constant
    let savedQuote: Quote
    
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
                                    EditReflectionView(
                                        savedQuote: savedQuote,
                                        quoteContent: savedQuote.text,
                                        quoteAuthor: savedQuote.author,
                                        userThoughts: savedQuote.reflection,
                                        successfulSave: {
                                        withAnimation(.spring().delay(0.25)) {
                                            saveIsSuccessful.toggle()
                                        }
                                    })
                                        .presentationDragIndicator(.visible)
                                }
                                .alert("Error",
                                       isPresented: $showAlert,
                                       presenting: alertMessage
                                ) { detail in
                                    Button("Please try again") {}
                                } message: { _ in
                                    Text(alertMessage)
                                }
                                .alert("Are you sure?",
                                       isPresented: $showDeleteQuoteAlert,
                                       presenting: Constants.AlertMessage.deleteQuoteAlertMessage
                                ) { _ in
                                    Button("Delete", role: .destructive) {
                                    // TODO: - Add method to delete the saved quote.
                                    }
                                } message: { _ in
                                    Text("Delete failed")
                                }
                        }
                    }
                }
                quoteContentView
                    .overlay {
                        if saveIsSuccessful {
                            CustomPopUpView(message: "Edit saved")
                                .transition(.scale.combined(with: .opacity))
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation(.spring()) {
                                            saveIsSuccessful.toggle()
                                        }
                                    }
                                }
                        }
                    }
                quoteAuthorView
            }
            .padding()
            .cardBackgroundModifier()
        }
    }
    
    // MARK: - UI Components
    private var menuButton: some View {
        Menu {
            Button {
                isPopoverPresented.toggle()
                presentActivityController()
            } label: {
                Label(
                    "Share this quote",
                    systemImage: "square.and.arrow.up"
                )
            }
            Button(
                "Edit your reflection",
                systemImage: "square.and.pencil"
            ) {
                isEditReflectionSheetPresented.toggle()
            }
            Button(role: .destructive) {
                showDeleteQuoteAlert.toggle()
            } label: {
                Label(
                    "Delete",
                    systemImage: "trash"
                )
            }
        } label: {
            Label(
                "",
                systemImage: "ellipsis.circle.fill"
            )
        }
        .accessibilityLabel("Menu")
    }
    
    struct QuoteSymbol: View {
        let isOpen: Bool
        
        var body: some View {
            HStack {
                if isOpen { Image(systemName: "quote.opening") }
                Spacer()
                if !isOpen { Image(systemName: "quote.closing") }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isOpen ? "Start quote" : "End quote")
        }
    }

    private var quoteContentView: some View {
        VStack {
            QuoteSymbol(isOpen: true)
            Text(savedQuote.text)
                .minimumScaleFactor(0.5)
                .padding([.leading, .trailing])
                .font(.callout)
            QuoteSymbol(isOpen: false)
        }
    }

    private var quoteAuthorView: some View {
        Text(savedQuote.author)
            .font(.callout)
    }
}

// MARK: - Activity controller methods
extension SavedCardView {
    private func presentActivityController() {
        var quoteToShare: String = ""
        quoteToShare = "\(savedQuote.text)" + " - " + "\(savedQuote.author)"
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

#Preview {
    SavedCardView(savedQuote: Quote.sample[0])
        .padding()
}
