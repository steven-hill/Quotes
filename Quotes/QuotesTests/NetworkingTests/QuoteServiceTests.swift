//
//  QuoteServiceTests.swift
//  QuotesTests
//
//  Created by Steven Hill on 29/07/2024.
//

import XCTest
@testable import Quotes

final class QuoteServiceTests: XCTestCase {
    
    private var url: URL!
    private var sut: QuoteService!
    private var mockCacheManager: MockCacheManager!
    
    lazy var mockSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()
    
    override func setUp() {
        url = URL(string: "https://zenquotes.io/api/today")
        mockCacheManager = MockCacheManager()
        sut = QuoteService(session: mockSession, cacheManager: mockCacheManager)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        url = nil
        mockCacheManager = nil
        sut = nil
        super.tearDown()
    }
    
    func test_FetchQuoteOfTheDay_URL_IsValid_And_ReturnsOneResult_And_CachesIt() async throws {
        let mockKey = "cachedDailyQuote"
        let mockData =
            """
            [ {"q":"When you want to be honored by others, you learn to honor them first.","a":"Sathya Sai Baba","h":"<blockquote>&ldquo;When you want to be honored by others, you learn to honor them first.&rdquo; &mdash; <footer>Sathya Sai Baba</footer></blockquote>"} ]
            """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, self.url.absoluteString)
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }
        let result = try await sut.fetchQuoteOfTheDay()
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(mockCacheManager.cachedItems.isEmpty)
        XCTAssertEqual(mockCacheManager.cachedItems.count, 1)
    }
    
    func test_FetchQuoteOfTheDay_DecodesCorrectly() async throws {
        let data =
            """
            [ {"q":"When you want to be honored by others, you learn to honor them first.","a":"Sathya Sai Baba","h":"<blockquote>&ldquo;When you want to be honored by others, you learn to honor them first.&rdquo; &mdash; <footer>Sathya Sai Baba</footer></blockquote>"} ]
            """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, data)
        }
        
        let mockQuoteService = MockQuoteService()
        let decodedData = mockQuoteService.readMockQuoteResponseJsonFile()
        let result = try await sut.fetchQuoteOfTheDay()
        
        XCTAssertEqual(decodedData, result)
    }
    
    func test_Response_IsValid_And_Has_InvalidStatusCode() async {
        let invalidStatusCode = 400
        let data = Data()
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, data)
        }
        
        do {
            let _ = try await sut.fetchQuoteOfTheDay()
        } catch {
            guard let networkError = error as? QuoteService.QuoteServiceError else {
                XCTFail("Wrong error type, expecting QuoteService.QuoteServiceError")
                return
            }
            XCTAssertEqual(networkError, QuoteService.QuoteServiceError.invalidStatusCode(statusCode: invalidStatusCode), "Expecting a networking error that throws invalid status code 400")
        }
    }
    
    func test_Response_IsValid_With_InvalidJSON() {
        let data = "Invalid Data".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (response!, data)
        }
        
        do {
            _ = try sut.decoder.decode(QuoteServiceResult.self, from: data)
        } catch {
            print(error.localizedDescription)
            if error is QuoteService.QuoteServiceError { 
                XCTFail("The error should be a JSON decoding error.")
            }
        }
    }
}
