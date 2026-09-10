//
//  QuoteOfTheDayViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import Observation

@Observable
final class QuoteOfTheDayViewModel {
    
    //MARK: - State Definition
    enum State: Equatable {
        case idle
        case loading
        case success
        case failure(NetworkError)
    }
    
    //MARK: - Properties
    private(set) var state: State = .idle
    private(set) var quoteContent: String = ""
    private(set) var quoteAuthor: String = ""
    private(set) var quoteToShare: String = ""
    var hasError: Bool = false
    
    //MARK: - Dependency
    private let networkClient: Networking
    
    //MARK: - Initialisation
    init(networkClient: Networking) {
        self.networkClient = networkClient
    }
    
    //MARK: - Method
    func getQuoteOfTheDay() async {
        self.state = .loading
        self.hasError = false
        do {
            let quoteOfTheDay = try await networkClient.fetchQuoteOfTheDay()
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
