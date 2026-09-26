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
    @State private var showDeleteConfirmation = false
    @State private var isEditReflectionSheetPresented = false
    @State private var saveIsSuccessful = false
    
    // MARK: - Dependencies
    private let savedQuote: Quote
    private let factory: ViewFactory
    private let onDelete: () -> Void
    
    // MARK: - Initialisation
    init(
        savedQuote: Quote,
        factory: ViewFactory,
        onDelete: @escaping () -> Void
    ) {
        self.savedQuote = savedQuote
        self.factory = factory
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    var body: some View {
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            menuButton
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
            .onTapGesture {
                isEditReflectionSheetPresented = true
            }
            .padding()
            .cardBackgroundModifier()
            .confirmationDialog(
                "Are you sure?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text(Constants.AlertMessage.deleteQuoteAlertMessage)
            }
        .sheet(isPresented: $isEditReflectionSheetPresented) {
            factory.makeEditReflectionView(
                savedQuote: savedQuote,
                userThoughts: savedQuote.reflection,
                successfulSave: {
                    withAnimation(.spring().delay(0.25)) {
                        saveIsSuccessful.toggle()
                    }
                })
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - UI Components
    private var menuButton: some View {
        Menu {
            ShareLink(
                item: "\(savedQuote.text) - \(savedQuote.author)"
            ) {
                Label(
                    "Share this quote",
                    systemImage: "square.and.arrow.up"
                )
            }
            Button(
                "Edit your reflection",
                systemImage: "square.and.pencil"
            ) {
                isEditReflectionSheetPresented = true
            }
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label(
                    "Delete",
                    systemImage: "trash"
                )
                .tint(.red)
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

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    let viewFactory = ViewFactory(dependencies: appContainer)
    SavedCardView(
        savedQuote: Quote.sample[0],
        factory: viewFactory,
        onDelete: {}
    )
    .padding()
}
