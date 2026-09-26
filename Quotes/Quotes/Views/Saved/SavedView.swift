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
                factory.makeSavedCardView(
                    savedQuote: savedQuote,
                    onDelete: { savedVM.delete(quote: savedQuote) }
                )
                .listRowSeparator(.hidden)
                .listRowClearBackgroundModifier()
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
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
