//
//  QuoteServiceResult.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

struct QuoteServiceResultElement: Decodable, Equatable {
    let q, a, h: String
}

typealias QuoteServiceResult = [QuoteServiceResultElement]

extension QuoteServiceResultElement {
    var quote: String { return q }
    var author: String { return a }
    var blockQuote: String { return h }
}
