//
//  SavedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI
import SwiftData

struct SavedView: View {
    
    // MARK: - Environment
    @Environment(\.isSearching) private var isSearching
    
    // MARK: - State
    @State private var showDeleteQuoteAlert: Bool = false
    @State private var quoteToDelete: Quote?
    @State private var savedVM: SavedViewModel
    
    // MARK: - Dependencies
    private let quoteRepository: QuoteRepository
    private let factory: ViewFactory
    
    // MARK: - Initialisation
    init(
        quoteRepository: QuoteRepository,
        factory: ViewFactory
    ) {
        self.quoteRepository = quoteRepository
        _savedVM = State(initialValue: SavedViewModel(repository: quoteRepository))
        self.factory = factory
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.inline)
                .pinkBluePurpleBackgroundModifier()
        }
        .task {
            savedVM.fetchAllQuotes()
        }
        .confirmationDialog(
            "Are you sure?",
            item: $savedVM.quoteToDelete
        ) { quote in
            Button("Delete", role: .destructive) {
                savedVM.delete(quote: quote)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text(Constants.AlertMessage.deleteQuoteAlertMessage)
        }
        .alert(item: $savedVM.alert) { alert in
            switch alert {
            case .loadingError(let message):
                Alert(
                    title: Text("Loading Error"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            case .deleteError(let message):
                Alert(
                    title: Text("Delete Error"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .searchable(
            text: $savedVM.searchText,
            prompt: "Search by author or quote"
        )
        .disabled(savedVM.isSearchDisabled)
    }
    
    // MARK: - UI Components
    @ViewBuilder
    private var content: some View {
        switch savedVM.contentState {
        case .noSearchResults:
            NoSearchResultsFoundView(searchQuery: $savedVM.searchText)
        case .noSavedQuotes:
            NoSavedQuotesView()
        case .savedQuotesList:
            savedQuotesList
        }
    }
    
    private var savedQuotesList: some View {
        List {
            ForEach(savedVM.quotes, id: \.id) { savedQuote in
                factory.makeSavedCardView(savedQuote: savedQuote)
                    .listRowSeparator(.hidden)
                    .listRowClearBackgroundModifier()
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: false
                    ) {
                        Button(role: .destructive) {
                            showDeleteQuoteAlert = true
                            quoteToDelete = savedQuote
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
            .alert("Error",
                   isPresented: $savedVM.hasError,
                   presenting: savedVM.errorMessage
            ) { _ in
                Button("Please try again") {}
            } message: { _ in
                if let message = savedVM.errorMessage {
                    Text(message)
                }
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .alert("Are you sure?",
               isPresented: $showDeleteQuoteAlert
        ) { 
            Button("Delete", role: .destructive) {
                if let quote = quoteToDelete {
                    savedVM.delete(quote: quote)
                }
            }
        } message: { 
            Text(Constants.AlertMessage.deleteQuoteAlertMessage)
        }
    }
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    let viewFactory = ViewFactory(dependencies: appContainer)
    SavedView(
        quoteRepository: appContainer.quoteRepository,
        factory: viewFactory
    )
}
