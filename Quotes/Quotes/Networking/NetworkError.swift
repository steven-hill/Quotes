//
//  NetworkError.swift
//  Quotes
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case networkConnectionOffline
    case invalidURL
    case invalidStatusCode(statusCode: Int)
    case invalidData
    case unknown(Error)
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
        case(.unknown(let lhsType), .unknown(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
