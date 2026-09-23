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
    
    // MARK: - Constants
    let deleteQuoteAlertMessage = "This action can't be undone."
    
    // MARK: - Dependency
    private let quoteRepository: QuoteRepository
    
    // MARK: - Initialisation
    init(quoteRepository: QuoteRepository) {
        self.quoteRepository = quoteRepository
        _savedVM = State(initialValue: SavedViewModel(repository: quoteRepository))
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
        .alert("Error",
               isPresented: $savedVM.hasError,
               presenting: savedVM.errorMessage
        ) { _ in
            Button("Retry") {
                savedVM.fetchAllQuotes()
            }
        } message: { _ in
            if let message = savedVM.errorMessage {
                Text(message)
            }
        }
        .searchable(
            text: $savedVM.searchText,
            prompt: "Search by author or quote"
        )
        .disabled(savedVM.isSearchDisabled)
    }
    
    // MARK: - Enum for Content States
    private enum ContentState {
        case noSearchResults
        case noSavedQuotes
        case savedQuotesList
    }
    
    // MARK: - Computed Property for Content State
    private var contentState: ContentState {
        if !savedVM.searchText.isEmpty && savedVM.quotes.isEmpty {
            return .noSearchResults
        } else if savedVM.quotes.isEmpty && !isSearching {
            return .noSavedQuotes
        } else {
            return .savedQuotesList
        }
    }
    
    // MARK: - UI Components
    @ViewBuilder
    private var content: some View {
        switch contentState {
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
                SavedCardView(savedQuote: savedQuote)
                    .listRowSeparator(.hidden)
                    .listRowClearBackgroundModifier()
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: false
                    ) {
                        Button(role: .destructive) {
                            showDeleteQuoteAlert.toggle()
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
               isPresented: $savedVM.hasError,
               presenting: savedVM.errorMessage
        ) { _ in
            Button("Delete", role: .destructive) {
                if let quote = quoteToDelete {
                    savedVM.delete(quote: quote)
                }
            }
        } message: { _ in
            if let message = savedVM.errorMessage {
                Text(message)
            }
        }
    }
}
    
//    // MARK: - Update search results method
//    private func updateSearchResults(_ newValue: FetchRequestStore.Search) {
//        if newValue.query.isEmpty && !isSearching {
//            fetched.reFetchAll()
//        } else {
//            fetched.filterListByAuthorOrQuote(with: newValue.query)
//        }
//    }
//}
//
//// MARK: - Remove quote method
//extension SavedView {
//    func removeQuote(at offsets: IndexSet) {
//        fetched.deleteQuote(atOffsets: offsets)
//    }
//}

#Preview {
    let previewContainer = AppContainer.makePreviewContainer(withSampleData: true)
    SavedView(quoteRepository: SwiftDataQuoteRepository(container: previewContainer))
}
