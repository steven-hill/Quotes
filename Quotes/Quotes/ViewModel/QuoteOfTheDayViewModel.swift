//
//  QuoteOfTheDayViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation

final class QuoteOfTheDayViewModel: ObservableObject {
    
    //MARK: - State Definition
    enum State: Equatable {
        case idle
        case loading
        case success
        case failure(NetworkError)
    }
    
    //MARK: - Properties
    @Published private(set) var state: State = .idle
    @Published var hasError: Bool = false
    @Published var quoteContent: String = ""
    @Published var quoteAuthor: String = ""
    @Published var quoteToShare: String = ""
    private let quoteService: Networking
    
    //MARK: - Initialisation
    init(quoteService: Networking) {
        self.quoteService = quoteService
    }
    
    //MARK: - Method
    func getQuoteOfTheDay() async {
        self.state = .loading
        self.hasError = false
        do {
            let quoteOfTheDay = try await quoteService.fetchQuoteOfTheDay()
            quoteContent = quoteOfTheDay.text
            quoteAuthor = quoteOfTheDay.author
            quoteToShare = quoteContent + " - " + quoteAuthor
            self.state = .success
        } catch {
            let networkError = NetworkError(from: error)
            self.state = .failure(networkError)
            self.hasError = true
        }
    }
}
