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
    var reflectionAlert: EditReflectionAlertState?
    
    //MARK: - Edit Reflection Alert State Definition
    enum EditReflectionAlertState: Identifiable, Equatable {
        case updateError(String)
        
        var id: String {
            switch self {
            case .updateError:
                return "Update error"
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
    func updateReflection(
        quote: Quote,
        reflection: String
    ) {
        guard let quoteID = quote.id else { return }
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
            reflectionAlert = .updateError(error.localizedDescription)
        }
    }
}
