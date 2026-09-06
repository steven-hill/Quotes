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
    private let session: NetworkSession
    private let decoder: JSONDecoder
    private let cache: URLCache
    private let quoteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    init(
        session: NetworkSession? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        cache: URLCache = .shared
    ) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = session ?? URLSession(configuration: config)
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .formatted(quoteDateFormatter)
        self.cache = cache
    }
    
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        /// Inspect `URLCache` first, comparing decoded object's date against user's current day.
        /// If cache is valid for today, skip network.
        let request = URLRequest(url: url)
        if let cachedResult = retrieveCacheResult(for: request) {
            return cachedResult
        }
            
        /// If `URLCache` is stale or empty, try the network.
        var networkRequest = request
        networkRequest.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await session.data(for: networkRequest)
        try validate(response)

        /// Decode and save the response to the cache.
        return try decodeAndCache(
            data: data,
            response: response,
            request: request
        )
    }
    
    //MARK: - Helpers
    private func retrieveCacheResult(for request: URLRequest) -> QuoteNetworkResult? {
        guard let cachedResponse = cache.cachedResponse(for: request),
              let networkResult = try? decoder.decode(QuoteNetworkResult.self, from: cachedResponse.data),
              let quote = networkResult.first  else {
            return nil
        }
        return Calendar.current.isDateInToday(quote.date) ? networkResult : nil
    }
    
    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }
    }
    
    private func decodeAndCache(
        data: Data,
        response: URLResponse,
        request: URLRequest
    ) throws -> QuoteNetworkResult {
        do {
            let result = try decoder.decode(QuoteNetworkResult.self, from: data)
            let cachedData = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedData, for: request)
            return result
        } catch {
            throw NetworkError.invalidData(error.localizedDescription)
        }
    }
}
