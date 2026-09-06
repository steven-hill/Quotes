//
//  StubNetworkSession.swift
//  QuotesTests
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation
@testable import Quotes

final class StubNetworkSession: NetworkSession {
    var lastRequest: URLRequest?
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    init(data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.lastRequest = request
        if let error = error {
            throw error
        }
        if let data = data, let response = response {
            return (data, response)
        }
        throw NetworkError.unknown
    }
}
