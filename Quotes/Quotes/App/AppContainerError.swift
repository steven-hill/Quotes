//
//  AppContainerError.swift
//  Quotes
//
//  Created by Steven Hill on 16/09/2026.
//

import Foundation

enum AppContainerError: Error, LocalizedError {
    case failedToInitialiseStorage(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .failedToInitialiseStorage:
            return "The app couldn't initialise its local storage."
        }
    }
    
    var recoverySuggestion: String? {
        recoveryMessage
    }
    
    var recoveryMessage: String {
        switch self {
        case .failedToInitialiseStorage:
            return "If device storage is low, try to free up some space and restart the app. If the problem persists, try reinstalling the app."
        }
    }
}

extension AppContainerError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .failedToInitialiseStorage(error: let error):
            return "AppContainerError.failedToInitialiseAnyStorage. Persistent and in-memory SwiftData store failed: \(error)"
        }
    }
}

extension AppContainerError {
    init(from error: Error) {
        self = .failedToInitialiseStorage(error: error)
    }
}
