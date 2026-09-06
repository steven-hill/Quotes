//
//  NetworkClientTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 05/09/2026.
//

import Testing
@testable import Quotes
import Foundation

struct NetworkClientTests {
    
    @MainActor @Test("When `URLCache` contains a cached response for today, `fetchQuoteOfTheDay` returns the cached response and skips the network")
    func networkClient_fetchQuoteOfTheDay_whenValidCacheExistsForToday_returnsCacheAndSkipsNetwork() async throws {
        let testURL = URL(string: "https://zenquotes.io/api/today")!
        let stubSession = StubNetworkSession()
        let ephemeralCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
        let today = createDateString(daysOffset: 0)
        let todaysData = createQuoteData(
            quote: "A",
            author: "A",
            dateString: today
        )
        let response = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let cachedResponse = CachedURLResponse(
            response: response,
            data: todaysData
        )
        let request = URLRequest(url: testURL)
        ephemeralCache.storeCachedResponse(cachedResponse, for: request)
        let sut = NetworkClient(session: stubSession, cache: ephemeralCache)
        
        let result = try await sut.fetchQuoteOfTheDay()
        
        let dateInResult = dateFormatter.string(from: result.first!.date)
        #expect(stubSession.lastRequest == nil, "Network call should not have been made when a valid daily cache exists.")
        #expect(stubSession.data == nil, "Should still be nil.")
        #expect(stubSession.response == nil, "Should still be nil.")
        #expect(stubSession.error == nil, "Should still be nil.")
        #expect(result.first?.text == "A", "Should match data in the cached response.")
        #expect(result.first?.author == "A", "Should match data in the cached response.")
        #expect(dateInResult == today, "The date in the network result should match the date of the cached response.")
    }
    
    @MainActor @Test("When `URLCache` contains yesterday's data, `fetchQuoteOfTheDay` fetches today's data from the network and overwrites cache")
    func networkClient_fetchQuoteOfTheDay_whenCacheIsStale_hitsNetworkAndOverwritesCache() async throws {
        let testURL = URL(string: "https://zenquotes.io/api/today")!
        let stubSession = StubNetworkSession()
        let ephemeralCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
        let yesterdayString = createDateString(daysOffset: -1)
        let yesterdaysData = createQuoteData(
            quote: "A",
            author: "A",
            dateString: yesterdayString
        )
        let response = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let cachedResponse = CachedURLResponse(
            response: response,
            data: yesterdaysData
        )
        let request = URLRequest(url: testURL)
        ephemeralCache.storeCachedResponse(cachedResponse, for: request)        
        let todayString = createDateString(daysOffset: 0)
        let todaysData = createQuoteData(
            quote: "B",
            author: "B",
            dateString: todayString
        )
        stubSession.data = todaysData
        stubSession.response = response
        let sut = NetworkClient(session: stubSession, cache: ephemeralCache)
        
        let result = try await sut.fetchQuoteOfTheDay()
        
        #expect(stubSession.lastRequest != nil, "Should have made a network request.")
        #expect(stubSession.data == todaysData, "Should have today's data, not yesterday's.")
        #expect(stubSession.response != nil, "Should not be nil.")
        #expect(stubSession.error == nil, "Should still be nil.")
        #expect(result.first?.text == "B", "Should match today's data, not the cache.")
        #expect(result.first?.author == "B", "Should match today's data, not the cache.")
        
        let dateInResult = dateFormatter.string(from: result.first!.date)
        #expect(dateInResult == todayString, "The date in the network result should not be yesterday because it should be overwritten with today's.")
    }
    
    @MainActor @Test("When server returns non-200 status code, should throw correct error")
    func networkClient_fetchQuoteOfTheDay_whenServerStatusCodeIsInvalid_throwsCorrectError() async throws {
        let testURL = URL(string: "https://zenquotes.io/api/today")!
        let statusCode = 429
        let networkResponse = HTTPURLResponse(
            url: testURL,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        let stubSession = StubNetworkSession(
            data: Data(),
            response: networkResponse
        )
        let ephemeralCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
        let sut = NetworkClient(session: stubSession, cache: ephemeralCache)
        
        do {
            _ = try await sut.fetchQuoteOfTheDay()
            Issue.record("Expected an error to be thrown, but network call succeeded.")
        } catch let error as NetworkError {
            if case .invalidStatusCode(statusCode: let code) = error {
                #expect(code == statusCode)
            } else {
                Issue.record("Expected `.invalidStatusCode` to be thrown, but got \(error).")
            }
        }
    }
    
    //MARK: - Helpers
    private func createDateString(daysOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let targetedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())!
        return formatter.string(from: targetedDate)
    }
    
    private func createQuoteData(
        quote: String,
        author: String,
        dateString: String
    ) -> Data {
            """
            [
              {
                "q": "\(quote)",
                "a": "\(author)",
                "date": "\(dateString)"
              }
            ]
            """.data(using: .utf8)!
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
