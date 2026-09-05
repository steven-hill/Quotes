//
//  NetworkClient.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

protocol Networking {
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult
}

final class NetworkClient: Networking {
    private let urlString = "https://zenquotes.io/api/today"
    private let cacheKey = "cachedDailyQuote"
    
    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let cacheManager: CacheProtocol
    
    init(
        session: NetworkSession? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        cacheManager: CacheProtocol
    ) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = session ?? URLSession(configuration: config)
        self.decoder = decoder
        self.cacheManager = cacheManager
    }
    
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult {
        if let cachedData = cacheManager.retrieve(key: cacheKey) {
            return try decoder.decode(QuoteNetworkResult.self, from: cachedData)
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }
        
        do {
            let result = try decoder.decode(QuoteNetworkResult.self, from: data)
            cacheManager.save(key: cacheKey, value: data)
            return result
        } catch {
            throw NetworkError.invalidData
        }
    }
}
