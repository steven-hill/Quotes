//
//  QuoteViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

final class QuoteViewModel: ObservableObject {
    
    enum State {
        case notAvailable
        case loading
        case success(data: QuoteServiceResult)
        case failure(error: Error)
    }
    
    @Published private(set) var state: State = .notAvailable
    @Published var hasError: Bool = false
    @Published var quoteContent: String = ""
    @Published var quoteAuthor: String = ""
    @Published var quoteToShare: String = ""
    
    private let quoteService: QuoteServiceProtocol
    
    init(quoteService: QuoteServiceProtocol) {
        self.quoteService = quoteService
    }
    
    @MainActor
    func getQuoteOfTheDay() async {
        self.state = .loading
        self.hasError = false
        do {
            let quoteOfTheDay = try await quoteService.fetchQuoteOfTheDay()
            quoteContent = quoteOfTheDay.first?.quote ?? "Content Unavailable"
            quoteAuthor = quoteOfTheDay.first?.author ?? "Author Name Unavailable"
            quoteToShare = quoteContent + " - " + quoteAuthor
            self.state = .success(data: quoteOfTheDay)
        } catch {
            self.state = .failure(error: error)
            self.hasError = true
        }
    }
}

extension QuoteViewModel.State: Equatable {
    static func == (lhs: QuoteViewModel.State, rhs: QuoteViewModel.State) -> Bool {
        switch(lhs, rhs) {
        case(.notAvailable, .notAvailable):
            return true
        case(.loading, .loading):
            return true
        case(.success(let lhsType), .success(let rhsType)):
            return lhsType == rhsType
        case(.failure(let lhsType), .failure(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
