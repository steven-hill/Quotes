//
//  SavedViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
import Combine

@Observable
final class SavedViewModel {
    
    // MARK: - Content State Definition
    enum ContentState {
        case noSavedQuotes
        case savedQuotesList
        case noSearchResults
    }
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Properties
    private(set) var quotes: [Quote] = []
    var hasError: Bool = false
    private(set) var errorMessage: String?
    private let searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    var searchText: String = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }
    var isSearchDisabled: Bool {
        quotes.isEmpty && searchText.isEmpty
    }
    var contentState: ContentState {
        if !searchText.isEmpty && quotes.isEmpty {
            return .noSearchResults
        } else if searchText.isEmpty && quotes.isEmpty {
            return .noSavedQuotes
        } else {
            return .savedQuotesList
        }
    }
    var quoteToDelete: Quote?
    var alert: AlertState?
    
    enum AlertState: Identifiable, Equatable {
        case loadingError(String)
        
        var id: String {
            switch self {
            case .loadingError:
                return "Loading error"
            }
        }
    }
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
        setupSearch()
    }
    
    //MARK: - Search-related Methods
    private func setupSearch() {
        searchSubject
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .map { [weak self] rawText in
                self?.cleanSearchText(rawText) ?? ""
            }
            .removeDuplicates()
            .sink { [weak self] query in
                self?.fetchAllQuotes(matching: query)
            }
            .store(in: &cancellables)
    }
    
    private func cleanSearchText(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //MARK: - Persistence-related Methods
    func fetchAllQuotes(matching query: String? = nil) {
        do {
            quotes = try repository.loadAllQuotes(matching: query ?? searchText)
        } catch {
            alert = .loadingError(error.localizedDescription)
        }
    }
    
    func update(
        quote: Quote,
        reflection: String
    ) {
        guard let quoteID = quote.id else {
            hasError = true
            errorMessage = "Unable to update quote."
            return
        }
        do {
            try repository.updateReflection(
                for: quoteID,
                reflection: reflection
            )
            fetchAllQuotes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func requestDelete(quote: Quote) {
        quoteToDelete = quote
    }
    
    func delete(quote: Quote) {
        guard let quote = quoteToDelete else { return }
        guard let quoteID = quote.id else {
            hasError = true
            errorMessage = "Unable to delete quote."
            return
        }
        do {
            try repository.delete(quoteID)
            fetchAllQuotes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
