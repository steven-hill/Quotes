//
//  EditReflectionViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 30/09/2026.
//

import Foundation

@Observable
final class EditReflectionViewModel {
    
    //MARK: - Properties
    private(set) var isReflectionUpdated: Bool = false
    var showConfirmationDialog: Bool = false
    
    //MARK: - Dependency
    private let repository: QuoteRepository
    
    //MARK: - Initialisation
    init(repository: QuoteRepository) {
        self.repository = repository
    }
    
    //MARK: - Method
    func updateReflection(
        quoteID: UUID,
        reflection: String
    ) {
        if reflection.isEmpty {
            showConfirmationDialog = true
            return
        }
        isReflectionUpdated = false
        do {
            try repository.updateReflection(
                for: quoteID,
                reflection: reflection
            )
            isReflectionUpdated = true
        } catch {
        
        }
    }
}
