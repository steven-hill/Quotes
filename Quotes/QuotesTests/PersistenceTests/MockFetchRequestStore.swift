//
//  MockFetchRequestStore.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/09/2024.
//

import Foundation
@testable import Quotes

class MockFetchRequestStore: FetchRequestStoreProtocol {
    
    enum FetchState {
        case none
        case success(data: [MockedSavedQuote])
        case failure(error: MockFetchError)
    }
    
    enum MockFetchError: Error {
        case fetchFailure
    }
    
    struct MockedSavedQuote: Equatable {
        let quoteContent: String
        let quoteAuthor: String
        let reflection: String
    }
    
    var fetchRequestHasError: Bool = false
    var savedQuotes: [MockedSavedQuote] = []
    var fetchSuccessful: Bool = true
    var fetchState: FetchState = .none
    
    func tryFetch() {
        if fetchSuccessful {
            fetchState = .success(data: savedQuotes)
        } else {
            fetchRequestHasError = true
            fetchState = .failure(error: MockFetchError.fetchFailure)
        }
    }
}

extension MockFetchRequestStore.FetchState: Equatable {
    static func == (lhs: MockFetchRequestStore.FetchState, rhs: MockFetchRequestStore.FetchState) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.success(lhsData), .success(rhsData)):
            return lhsData == rhsData
        case let (.failure(lhsError), .failure(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
