//
//  NetworkSession.swift
//  Quotes
//
//  Created by Steven Hill on 05/09/2026.
//

import Foundation

protocol NetworkSession {
    var configuration: URLSessionConfiguration { get }
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
