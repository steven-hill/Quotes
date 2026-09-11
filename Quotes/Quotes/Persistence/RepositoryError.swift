//
//  RepositoryError.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

/// Used for local database operations.
enum RepositoryError: Error, Sendable {
    case fetchFailed(underlying: Error)
    case quoteNotFound
    case updateFailed(underlying: Error)
}

// MARK: - User-Facing Descriptions
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

// MARK: - Developer-Facing Diagnostics
extension RepositoryError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .fetchFailed(let error):
            let nsError = error as NSError
            return "[RepositoryError.fetchFailed] Domain: \(nsError.domain), Code: \(nsError.code). Details: \(nsError.localizedDescription)"
        case .quoteNotFound:
            return "[RepositoryError.quoteNotFound] Query returned an empty dataset or target UUID matches no existing record."
        case .updateFailed(let error):
            let nsError = error as NSError
            return "[RepositoryError.updateFailed] Underlying storage layer error: \(nsError.localizedDescription)"
        }
    }
}

//MARK: - Equatable Conformance
extension RepositoryError: Equatable {
    static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.quoteNotFound, .quoteNotFound): return true
        case (.fetchFailed(let l), .fetchFailed(let r)): return (l as NSError) == (r as NSError)
        case (.updateFailed(let l), .updateFailed(let r)): return (l as NSError) == (r as NSError)
        default: return false
        }
    }
}
