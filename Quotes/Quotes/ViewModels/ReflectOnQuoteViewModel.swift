//
//  ReflectOnQuoteViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import Foundation

@Observable
final class ReflectOnQuoteViewModel {
    
    //MARK: - Properties
    private(set) var isQuoteSaved: Bool = false
    var hasError: Bool = false
    var errorMessage: String = ""
    var showConfirmationDialog: Bool = false
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
    }
    
    //MARK: - Method
    func saveQuoteWithReflection(
        quote: Quote,
        reflection: String
    ) {
        if reflection.isEmpty {
            showConfirmationDialog = true
            return
        }
        var quoteToSave = quote
        quoteToSave.reflection = reflection
        isQuoteSaved = false
        do {
            try repository.add(quoteToSave)
            isQuoteSaved = true
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
        }
    }
}
