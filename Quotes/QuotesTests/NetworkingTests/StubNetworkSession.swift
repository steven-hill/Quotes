//
//  StubNetworkSession.swift
//  QuotesTests
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation
@testable import Quotes

struct StubNetworkSession: NetworkSession {
    var configuration: URLSessionConfiguration
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    init(configuration: URLSessionConfiguration = .ephemeral,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil) {
        self.configuration = configuration
        self.data = data
        self.response = response
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        if let data = data, let response = response {
            return (data, response)
        }
        throw NetworkError.unknown
    }
}
