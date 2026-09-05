//
//  NetworkError.swift
//  Quotes
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation

enum NetworkError: Error, Equatable {
    case networkConnectionOffline
    case networkConnectionLost
    case networkTimeout
    case invalidURL
    case invalidResponse
    case invalidStatusCode(statusCode: Int)
    case invalidData(String)
    case unknown
}

// MARK: - User Facing Descriptions
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkConnectionOffline:
            return "No network connection."
        case .networkConnectionLost:
            return "Network connection was lost."
        case .networkTimeout:
            return "Network connection timed out."
        case .invalidURL, .invalidResponse, .invalidData, .unknown:
            return "Something went wrong."
        case .invalidStatusCode(let statusCode):
            return "Invalid response from server (Status: \(statusCode))."
        }
    }
}

// MARK: - Debugging Descriptions
extension NetworkError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .networkConnectionOffline:
            return "NetworkError.noInternetConnection"
        case .networkConnectionLost:
            return "NetworkError.networkConnectionLost"
        case .networkTimeout:
            return "NetworkError.networkTimeout"
        case .invalidURL:
            return "NetworkError.invalidURL"
        case .invalidResponse:
            return "NetworkError.invalidResponse"
        case .invalidStatusCode(let statusCode):
            return "NetworkError.serverError(statusCode: \(statusCode))"
        case .invalidData(let context):
            return "NetworkError.decodingError: \(context)"
        case .unknown:
            return "NetworkError.unknown"
        }
    }
}

// MARK: - Mapping Logic
extension NetworkError {
    /// Maps generic network or system errors into a `NetworkError`.
    init(from error: Error) {
        if let apiError = error as? NetworkError {
            self = apiError
            return
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                self = .networkConnectionOffline
            case .networkConnectionLost:
                self = .networkConnectionLost
            case .timedOut:
                self = .networkTimeout
            default:
                self = .unknown
            }
            return
        }
        
        if let decodingError = error as? DecodingError {
            self = .invalidData(decodingError.failureReason ?? decodingError.localizedDescription)
            return
        }
        
        self = .unknown
    }
}
