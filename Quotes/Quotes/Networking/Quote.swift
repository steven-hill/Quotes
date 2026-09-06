//
//  Quote.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

/// Model for network response.
struct Quote: Codable, Equatable {
    let text: String
    let author: String
    let date: Date
    
    private enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
        case date = "date"
    }
}

typealias QuoteNetworkResult = [Quote]

extension Quote {
    static let sample = [
        Quote(
            text: "However difficult life may seem, there is always something you can do and succeed at.",
            author: "Stephen Hawking",
            date: Date()
        )
    ]
}
