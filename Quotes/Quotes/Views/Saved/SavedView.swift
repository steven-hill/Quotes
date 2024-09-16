//
//  SavedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct SavedView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.isSearching) private var isSearching
    @ObservedObject var fetched: FetchRequestStore
    @State private var searchText: FetchRequestStore.Search = .init()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            if !searchText.query.isEmpty && fetched.filteredResults.isEmpty {
                NoSearchResultsFoundView(searchQuery: $searchText.query)
                    .navigationTitle("Saved")
            } else if fetched.savedQuotes.isEmpty && !isSearching {
                NoSavedQuotesView()
                    .navigationTitle("Saved")
            } else {
                List {
                    ForEach(fetched.savedQuotes, id: \.objectID) { savedQuote in
                        SavedCardView(savedQuote: savedQuote)
                            .navigationTitle("Saved")
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    do {
                                        try PersistenceController.shared.delete(savedQuote: savedQuote)
                                    } catch {
                                        showAlert.toggle()
                                        alertMessage = PersistenceController.shared.persistenceError.localizedDescription
                                    }
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
            }
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
        .searchable(text: $searchText.query, prompt: "Search by author")
        .onChange(of: searchText) { _, newValue in
            if searchText.query.isEmpty && !isSearching {
                fetched.reFetchAll()
            } else {
                fetched.filterListByAuthor(with: newValue.query)
            }
        }
    }
}

extension SavedView {
    func removeQuote(at offsets: IndexSet) {
        fetched.deleteQuote(atOffsets: offsets)
    }
}
