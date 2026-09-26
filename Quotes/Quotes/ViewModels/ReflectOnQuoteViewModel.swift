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
    var showConfirmationDialog: Bool = false
    var alert: AlertState?
    
    //MARK: - AlertState Definition
    enum AlertState: Identifiable, Equatable {
        case addError(String)
        
        var id: String {
            switch self {
            case .addError:
                return "add Error"
            }
        }
    }
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
    }
    
    //MARK: - Method
    func saveQuoteWithReflection(
        quoteContent: String,
        quoteAuthor: String,
        reflection: String
    ) {
        if reflection.isEmpty {
            showConfirmationDialog = true
            return
        }
        isQuoteSaved = false
        do {
            let quote = Quote(
                id: nil,
                text: quoteContent,
                author: quoteAuthor,
                date: Date(),
                reflection: reflection
            )
            try repository.add(quote)
            isQuoteSaved = true
        } catch {
            alert = .addError(error.localizedDescription)
        }
    }
}
