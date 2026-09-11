//
//  SavedViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

final class SavedViewModel {
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Properties
    private(set) var quotes: [Quote] = []
    private(set) var hasError: Bool = false
    private(set) var errorMessage: String?
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
    }
    
    //MARK: - Methods
    func fetchAllQuotes() {
        do {
            quotes = try repository.loadAllQuotes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func add(quote: Quote) {
        do {
            try repository.add(quote)
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
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
