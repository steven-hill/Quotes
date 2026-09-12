//
//  SavedViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation
import Combine

final class SavedViewModel {
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Properties
    private(set) var quotes: [Quote] = []
    private(set) var hasError: Bool = false
    private(set) var errorMessage: String?
    private let searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    var searchText: String = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
        setupSearch()
    }
    
    //MARK: - Methods
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
    
    func fetchAllQuotes(matching query: String? = nil) {
        do {
            quotes = try repository.loadAllQuotes(matching: query ?? searchText)
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func add(quote: Quote) {
        do {
            try repository.add(quote)
            fetchAllQuotes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
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
    
    func delete(quote: Quote) {
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
