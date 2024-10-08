//
//  QuoteService.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

protocol QuoteServiceProtocol {
    func fetchQuoteOfTheDay() async throws -> QuoteServiceResult
}

final class QuoteService: QuoteServiceProtocol {
    
    enum QuoteServiceError: Error, LocalizedError {
        case networkConnectionOffline
        case invalidURL
        case invalidStatusCode(statusCode: Int)
        case invalidData
        case unknown(Error)
    }
    
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
            throw QuoteServiceError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let statusCode = (response as! HTTPURLResponse).statusCode
            throw QuoteServiceError.invalidStatusCode(statusCode: statusCode)
        }
        
        cacheManager.save(key: cacheKey, value: data)
        
        do {
            return try decoder.decode(QuoteServiceResult.self, from: data)
        } catch {
            throw QuoteServiceError.invalidData
        }
    }
}

extension QuoteService.QuoteServiceError: Equatable {
    static func == (lhs: QuoteService.QuoteServiceError, rhs: QuoteService.QuoteServiceError) -> Bool {
        switch(lhs, rhs) {
        case(.networkConnectionOffline, .networkConnectionOffline):
            return true
        case(.invalidURL, .invalidURL):
            return true
        case(.invalidStatusCode(let lhsType), .invalidStatusCode(let rhsType)):
            return lhsType == rhsType
        case(.invalidData, .invalidData):
            return true
        case(.unknown(let lhsType), .unknown(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
