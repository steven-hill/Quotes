//
//  NetworkClient.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

protocol Networking {
    func fetchQuoteOfTheDay() async throws -> QuoteServiceResult
}

final class NetworkClient: Networking {
    private let URLString = "https://zenquotes.io/api/today"
    private let cacheKey = "cachedDailyQuote"
    
    let session: URLSession
    let decoder: JSONDecoder
    let cacheManager: CacheProtocol
    
    init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder(), cacheManager: CacheProtocol) {
        self.session = session
        self.decoder = decoder
        self.cacheManager = cacheManager
    }
    
    func fetchQuoteOfTheDay() async throws -> QuoteServiceResult {
        if let cachedData = cacheManager.retrieve(key: cacheKey) {
            return try decoder.decode(QuoteServiceResult.self, from: cachedData)
        }

        guard let url = URL(string: URLString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }
        
        cacheManager.save(key: cacheKey, value: data)
        
        do {
            return try decoder.decode(QuoteServiceResult.self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
}
