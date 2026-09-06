//
//  StubNetworkSession.swift
//  QuotesTests
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation
@testable import Quotes

actor StubNetworkSession: NetworkSession {
    var lastRequest: URLRequest?
    var data: Data?
    var response: URLResponse?
    
    init(data: Data? = nil,
        response: URLResponse? = nil) {
        self.data = data
        self.response = response
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.lastRequest = request
        if let data = data, let response = response {
            return (data, response)
        }
        throw NetworkError.unknown
    }
}
