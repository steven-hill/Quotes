//
//  SavedViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

final class SavedViewModel {
    private let repository: QuoteRepository
    private(set) var quotes: [Quote] = []
    
    init(repository: QuoteRepository) {
        self.repository = repository
    }
    
    func fetchAllQuotes() throws {
        quotes = try repository.loadAllQuotes()
    }
}
