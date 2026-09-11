//
//  RepositoryError.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

enum RepositoryError: Error, Equatable {
    case fetchFailed
    case quoteNotFound
    case updateFailed
}

// MARK: - User Facing Descriptions
extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch quotes from database."
        case .quoteNotFound:
            return "Quote not found in database."
        case .updateFailed:
            return "Failed to update quote in database."
        }
    }
}
