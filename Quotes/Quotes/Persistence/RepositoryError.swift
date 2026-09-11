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
    case addFailed(underlying: Error)
    case quoteNotFound
    case updateFailed(underlying: Error)
    case deleteFailed(underlying: Error)
}

// MARK: - User-Facing Descriptions
extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch quotes from database."
        case .addFailed:
            return "Failed to add quote to database."
        case .quoteNotFound:
            return "Quote not found in database."
        case .updateFailed:
            return "Failed to update quote in database."
        case .deleteFailed:
            return "Failed to delete quote from database."
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
        case .addFailed(let error):
            let nsError = error as NSError
            return "[RepositoryError.addFailed] Underlying storage layer error: \(nsError.localizedDescription)"
        case .quoteNotFound:
            return "[RepositoryError.quoteNotFound] Query returned an empty dataset or target UUID matches no existing record."
        case .updateFailed(let error):
            let nsError = error as NSError
            return "[RepositoryError.updateFailed] Underlying storage layer error: \(nsError.localizedDescription)"
        case .deleteFailed(underlying: let error):
            let nsError = error as NSError
            return "[RepositoryError.deleteFailed] Underlying storage layer error: \(nsError.localizedDescription)"
        }
    }
}

//MARK: - Equatable Conformance
extension RepositoryError: Equatable {
    static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.quoteNotFound, .quoteNotFound): return true
        case (.fetchFailed(let l), .fetchFailed(let r)): return (l as NSError) == (r as NSError)
        case (.addFailed(let l), .addFailed(let r)): return (l as NSError) == (r as NSError)
        case (.updateFailed(let l), .updateFailed(let r)): return (l as NSError) == (r as NSError)
        case (.deleteFailed(let l), .deleteFailed(let r)): return (l as NSError) == (r as NSError)
        default: return false
        }
    }
}
