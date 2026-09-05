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
    
    private let quoteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
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
        self.decoder.dateDecodingStrategy = .formatted(quoteDateFormatter)
        self.cacheManager = cacheManager
    }
    
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult {
        if let cachedData = cacheManager.retrieve(key: cacheKey) {
            return try decoder.decode(QuoteNetworkResult.self, from: cachedData)
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        /// Inspect `URLCache` first, comparing decoded object's date against user's current day.
        /// If cache is valid for today, skip network.
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let networkResult = try? decoder.decode(QuoteNetworkResult.self, from: cachedResponse.data),
           let quote = networkResult.first {
            if Calendar.current.isDateInToday(quote.date) {
                return networkResult
            }
        }
            
        /// If `URLCache` is stale or empty, try the network.
        var networkRequest = request
        networkRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await session.data(for: networkRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }

        do {
            let result = try decoder.decode(QuoteNetworkResult.self, from: data)
            /// Store valid response to cache for any more network requests today.
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)
            return result
        } catch {
            throw NetworkError.invalidData(error.localizedDescription)
        }
    }
}
