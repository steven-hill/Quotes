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
    
    @MainActor @Test("When URLCache contains a cached response for today, `fetchQuoteOfTheDay` returns the cached response and skips the network")
    func networkClient_fetchQuoteOfTheDay_whenValidCacheExistsForToday_returnsCacheAndSkipsNetwork() async throws {
        let testURL = URL(string: "https://zenquotes.io/api/today")!
        let stubSession = StubNetworkSession()
        let ephemeralCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
        let today = createDateString(daysOffset: 0)
        let sampleData = createSampleQuoteData(dateString: today)
        let response = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let cachedResponse = CachedURLResponse(
            response: response,
            data: sampleData
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
        #expect(dateInResult == today, "The date in the network result should match the date of the cached response.")
    }
    
    @MainActor @Test("When URLCache contains stale data, `fetchQuoteOfTheDay` fetches new data from the network and overwrites cache")
    func networkClient_fetchQuoteOfTheDay_whenCacheIsStale_hitsNetworkAndOverwritesCache() async throws {
        let testURL = URL(string: "https://zenquotes.io/api/today")!
        let stubSession = StubNetworkSession()
        let ephemeralCache = URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
        let yesterdayString = createDateString(daysOffset: -1)
        let staleData = createSampleQuoteData(dateString: yesterdayString)
        let response = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let cachedResponse = CachedURLResponse(
            response: response,
            data: staleData
        )
        let request = URLRequest(url: testURL)
        ephemeralCache.storeCachedResponse(cachedResponse, for: request)        
        let todayString = createDateString(daysOffset: 0)
        let freshData = createSampleQuoteData(dateString: todayString)
        stubSession.data = freshData
        stubSession.response = response
        let sut = NetworkClient(session: stubSession, cache: ephemeralCache)
        
        let result = try await sut.fetchQuoteOfTheDay()
        
        #expect(stubSession.lastRequest != nil, "Should have made a network request.")
        #expect(stubSession.data == freshData, "Should have today's data, not yesterday's.")
        #expect(stubSession.response != nil, "Should not be nil.")
        #expect(stubSession.error == nil, "Should still be nil.")
        
        let dateInResult = dateFormatter.string(from: result.first!.date)
        #expect(dateInResult == todayString, "The date in the network result should not be yesterday because it should be overwritten with today's.")
    }
    
    //MARK: - Helpers
    private func createDateString(daysOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let targetedDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())!
        return formatter.string(from: targetedDate)
    }
    
    private func createSampleQuoteData(dateString: String) -> Data {
            """
            [
              {
                "q": "Test Quote",
                "a": "Test Author",
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
