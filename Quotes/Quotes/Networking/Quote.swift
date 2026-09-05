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
    
    private enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
    }
}

typealias QuoteNetworkResult = [Quote]
