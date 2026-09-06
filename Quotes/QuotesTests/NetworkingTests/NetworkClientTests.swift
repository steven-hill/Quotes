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
        stubSession.configuration.urlCache = ephemeralCache
        let today = createDateString(daysOffset: 0)
        let sampleData = createSampleQuoteData(dateString: today)
        let response = HTTPURLResponse(
            url: testURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let cachedResponse = CachedURLResponse(response: response, data: sampleData)
        let request = URLRequest(url: testURL)
        ephemeralCache.storeCachedResponse(cachedResponse, for: request)
        let sut = NetworkClient(session: stubSession)
        
        let result = try await sut.fetchQuoteOfTheDay()
        
        let dateInResult = backendDateFormatter.string(from: result.first!.date)
        #expect(stubSession.lastRequest == nil, "Network call should not have been made when a valid daily cache exists.")
        #expect(dateInResult == today, "The date in the network result should match the date of the cached response.")
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
    
    private let backendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
