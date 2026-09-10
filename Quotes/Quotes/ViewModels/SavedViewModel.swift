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
    
    //MARK: - Method
    func fetchAllQuotes() throws {
        do {
            quotes = try repository.loadAllQuotes()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
