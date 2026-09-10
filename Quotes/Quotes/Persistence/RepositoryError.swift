//
//  RepositoryError.swift
//  Quotes
//
//  Created by Steven Hill on 10/09/2026.
//

import Foundation

enum RepositoryError: Error {
    case fetchFailed(underlying: Error)
}

// MARK: - User Facing Descriptions
extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to fetch quotes from database."
        }
    }
}

// MARK: - Debugging Descriptions
extension RepositoryError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .fetchFailed(let error):
            return "RepositoryError.fetchFailed: \(error.localizedDescription)"
        }
    }
}
