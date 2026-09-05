//
//  NetworkError.swift
//  Quotes
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation

enum NetworkError: Error {
    case networkConnectionOffline
    case networkConnectionLost
    case networkTimeout
    case invalidURL
    case invalidResponse
    case invalidStatusCode(statusCode: Int)
    case invalidData
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
        
        if error is DecodingError {
            self = .invalidData
            return
        }
        
        self = .unknown
    }
}

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch(lhs, rhs) {
        case(.networkConnectionOffline, .networkConnectionOffline):
            return true
        case(.invalidURL, .invalidURL):
            return true
        case(.invalidStatusCode(let lhsType), .invalidStatusCode(let rhsType)):
            return lhsType == rhsType
        case(.invalidData, .invalidData):
            return true
        case(.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
