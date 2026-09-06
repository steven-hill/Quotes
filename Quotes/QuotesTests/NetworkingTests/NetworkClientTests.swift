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
        let today = createDateString(daysOffset: 0)
        let todaysData = createQuoteData(
            quote: "A",
            author: "A",
            dateString: today
        )
        let stubSession = StubNetworkSession()
        let cache = makeTestCache()
        seedCache(cache, with: todaysData)
        let sut = NetworkClient(
            session: stubSession,
            cache: cache
        )
        
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
        let yesterdaysData = createQuoteData(
            quote: "A",
            author: "A",
            dateString: createDateString(daysOffset: -1)
        )
        let todayString = createDateString(daysOffset: 0)
        let todaysData = createQuoteData(
            quote: "B",
            author: "B",
            dateString: todayString
        )
        let stubSession = StubNetworkSession(
            data: todaysData,
            response: makeHTTPResponse(statusCode: 200)
        )
        let cache = makeTestCache()
        seedCache(cache, with: yesterdaysData)
        let sut = NetworkClient(
            session: stubSession,
            cache: cache
        )
        
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
    
    @MainActor @Test("When server returns invalid response, should throw correct error")
    func networkClient_fetchQuoteOfTheDay_whenHTTPResponseIsInvalid_throwsCorrectError() async {
        let testURL = makeTestURL()
        let invalidResponse = URLResponse(
            url: testURL,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        let stubSession = StubNetworkSession(
            data: Data(),
            response: invalidResponse
        )
        let sut = NetworkClient(session: stubSession, cache: makeTestCache())
        
        await #expect(throws: NetworkError.invalidResponse, "Should be `.invalidResponse`.") {
            try await sut.fetchQuoteOfTheDay()
        }
    }
    
    @MainActor @Test("When server returns non-200 status code, should throw correct error")
    func networkClient_fetchQuoteOfTheDay_whenServerStatusCodeIsInvalid_throwsCorrectError() async throws {
        let statusCode = 429
        let response = makeHTTPResponse(statusCode: statusCode)
        let stubSession = StubNetworkSession(
            data: Data(),
            response: response
        )
        let sut = NetworkClient(session: stubSession, cache: makeTestCache())
        
        await #expect(throws: NetworkError.invalidStatusCode(statusCode: statusCode), "Should be `.invalidStatusCode`.") {
            try await sut.fetchQuoteOfTheDay()
        }
    }
    
    @MainActor @Test("When server returns malformed JSON, should throw correct error")
    func networkClient_fetchQuoteOfTheDay_whenServerReturnsMalformedJSON_throwsCorrectError() async throws {
        let corruptData = "{\"invalid_json\": true".data(using: .utf8)!
        let response = makeHTTPResponse(statusCode: 200)
        let stubSession = StubNetworkSession(
            data: corruptData,
            response: response
        )
        let sut = NetworkClient(session: stubSession, cache: makeTestCache())
        
        let context = "The data couldn’t be read because it isn’t in the correct format."
        await #expect(throws: NetworkError.invalidData(context), "Should be `.invalidData`.") {
            try await sut.fetchQuoteOfTheDay()
        }
    }
    
    //MARK: - Helpers
    private func makeTestURL() -> URL {
        URL(string: "https://zenquotes.io/api/today")!
    }
    
    private func makeTestCache() -> URLCache {
        URLCache(memoryCapacity: 1 * 1024 * 1024, diskCapacity: 0, directory: nil)
    }
    
    @MainActor private func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: makeTestURL(),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    @MainActor private func seedCache(
        _ cache: URLCache,
        with data: Data
    ) {
        let cachedResponse = CachedURLResponse(
            response: makeHTTPResponse(statusCode: 200),
            data: data
        )
        let request = URLRequest(url: makeTestURL())
        cache.storeCachedResponse(cachedResponse, for: request)
    }
    
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
