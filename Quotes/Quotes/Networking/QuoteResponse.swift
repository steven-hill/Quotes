//
//  QuoteResponse.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

/// Model for network response.
struct QuoteResponse: Codable, Equatable {
    let text: String
    let author: String
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
        case date = "date"
    }
}

extension QuoteResponse {
    static let sample = QuoteResponse(
        text: "However difficult life may seem, there is always something you can do and succeed at.",
        author: "Stephen Hawking",
        date: "2026-09-08"
    )
}
