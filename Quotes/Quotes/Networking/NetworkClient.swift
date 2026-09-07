//
//  NetworkClient.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

nonisolated
protocol Networking {
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult
}

nonisolated
final class NetworkClient: Networking {
    //MARK: - Properties
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
    
    //MARK: - Initialisation
    init(
        session: NetworkSession? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        cache: URLCache = makeCache()
    ) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.urlCache = cache
        self.session = session ?? URLSession(configuration: config)
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .formatted(quoteDateFormatter)
        self.cache = cache
    }
    
    //MARK: - Method
    func fetchQuoteOfTheDay() async throws -> QuoteNetworkResult {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        /// Check `URLCache` first, comparing decoded object's date against the current date.
        /// If cache has today's quote, return it and skip the network request.
        let request = URLRequest(url: url)
        if let cachedResult = retrieveCacheResult(for: request) {
            return cachedResult
        }
            
        /// `URLCache` contains yesterday's data or is empty, so try the network.
        /// Avoid the `URLSession` HTTP requests cache.
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
    
    //MARK: - Cache Factory
    /// Creates a specifically configured cache for one, small JSON response.
    private static func makeCache() -> URLCache {
        URLCache(
            memoryCapacity: 1 * 1024 * 1024,
            diskCapacity: 5 * 1024 * 1024
        )
    }
    
    //MARK: - Helpers
    private func retrieveCacheResult(for request: URLRequest) -> QuoteNetworkResult? {
        guard let cachedResponse = cache.cachedResponse(for: request),
              let networkResult = try? decoder.decode(
                QuoteNetworkResult.self,
                from: cachedResponse.data
              ),
              let quote = networkResult.first else {
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
