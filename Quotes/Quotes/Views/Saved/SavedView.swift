//
//  SavedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct SavedView: View {
    
    // MARK: - Environment
    @Environment(\.isSearching) private var isSearching
    
    // MARK: - Environment object
    @EnvironmentObject var fetched: FetchRequestStore
    
    // MARK: - State
    @State private var searchText: FetchRequestStore.Search = .init()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteQuoteAlert: Bool = false
    @State private var quoteToDelete: SavedQuote?
    
    // MARK: - Constants
    let deleteQuoteAlertMessage = "This action can't be undone."
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Saved")
                .navigationBarTitleDisplayMode(.inline)
                .pinkBluePurpleBackgroundModifier()
        }
        .alert("Error", isPresented: $fetched.fetchRequestHasError, presenting: fetched.fetchState) { detail in
            Button("Retry") {
                fetched.tryFetch()
            }
        } message: { detail in
            if case let .failure(error) = detail {
                Text(error.localizedDescription)
            }
        }
        .searchable(text: $searchText.query, prompt: "Search by author or quote")
        .disabled(isSearchDisabled)
        .onChange(of: searchText) { _, newValue in
            updateSearchResults(newValue)
        }
    }
    
    // MARK: - Enum for Content States
    private enum ContentState {
        case noSearchResults
        case noSavedQuotes
        case savedQuotesList
    }
    
    // MARK: - Computed Property for Content State
    private var contentState: ContentState {
        if !searchText.query.isEmpty && fetched.filteredResults.isEmpty {
            return .noSearchResults
        } else if !searchText.query.isEmpty && fetched.savedQuotes.isEmpty {
            return .noSearchResults
        } else if fetched.savedQuotes.isEmpty && !isSearching {
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
            NoSearchResultsFoundView(searchQuery: $searchText.query)
        case .noSavedQuotes:
            NoSavedQuotesView()
        case .savedQuotesList:
            savedQuotesList
        }
    }
    
    private var savedQuotesList: some View {
        List {
            ForEach(fetched.savedQuotes, id: \.objectID) { savedQuote in
                SavedCardView(savedQuote: savedQuote)
                    .listRowSeparator(.hidden)
                    .listRowClearBackgroundModifier()
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            showDeleteQuoteAlert.toggle()
                            quoteToDelete = savedQuote
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
            .onDelete(perform: removeQuote)
            .alert("Error", isPresented: $showAlert, presenting: alertMessage) { detail in
                Button("Please try again") {}
            } message: { detail in
                Text(alertMessage)
            }
        }
        .listStyle(PlainListStyle())
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.viewWidth : .infinity)
        .alert("Are you sure?", isPresented: $showDeleteQuoteAlert, presenting: quoteToDelete) { quoteToDelete in
            Button("Delete", role: .destructive) {
                do {
                    try PersistenceController.shared.delete(savedQuote: quoteToDelete)
                } catch {
                    showAlert.toggle()
                    alertMessage = PersistenceController.shared.persistenceError.localizedDescription
                }
            }
        } message: { _ in
            Text(deleteQuoteAlertMessage)
        }
    }
    
    // MARK: - Disable search bar based on content state
    private var isSearchDisabled: Bool {
        if case .noSavedQuotes = contentState {
            return true
        }
        return false
    }
    
    // MARK: - Update search results method
    private func updateSearchResults(_ newValue: FetchRequestStore.Search) {
        if newValue.query.isEmpty && !isSearching {
            fetched.reFetchAll()
        } else {
            fetched.filterListByAuthorOrQuote(with: newValue.query)
        }
    }
}

// MARK: - Remove quote method
extension SavedView {
    func removeQuote(at offsets: IndexSet) {
        fetched.deleteQuote(atOffsets: offsets)
    }
}

#Preview {
    SavedView()
        .environmentObject(FetchRequestStore(managedObjectContext: PersistenceController.preview.container.viewContext))
}
