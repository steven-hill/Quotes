//
//  AppContainer.swift
//  Quotes
//
//  Created by Steven Hill on 13/09/2026.
//

import Foundation
import SwiftData

final class AppContainer {
    
    // MARK: - Properties
    private let modelContainer: ModelContainer
    private let schema = Schema(PersistedQuote.self)
    let quoteRepository: QuoteRepository
    let networkClient: Networking
    private(set) var isRunningInDegradedMode = false
    
    // MARK: - Initialisation
    init(isInMemoryOnly: Bool = false) {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: isInMemoryOnly)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            self.quoteRepository = SwiftDataQuoteRepository(container: modelContainer)
        } catch {
            self.isRunningInDegradedMode = true
            #if DEBUG
            print("Persistent SwiftData store failed:", error)
            #endif
            do {
                let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
                self.quoteRepository = SwiftDataQuoteRepository(container: modelContainer)
            } catch {
                fatalError("Failed to initialise SwiftData ModelContainer in degraded mode: \(error.localizedDescription)")
            }
        }
        self.networkClient = NetworkClient()
    }
    
    //MARK: - In-memory Model Container
    static func makePreviewContainer(withSampleData: Bool = true) -> ModelContainer {
        let container = AppContainer(isInMemoryOnly: true)
        if withSampleData {
            let sampleQuotes = [
                Quote(
                    id: nil,
                    text: "The only limit to our realization of tomorrow is our doubts of today.",
                    author: "FDR",
                    date: Date()
                ),
                Quote(
                    id: nil,
                    text: "Be yourself; everyone else is already taken.",
                    author: "Oscar Wilde",
                    date: Date()
                )
            ]
            for quote in sampleQuotes {
                try? container.quoteRepository.add(quote)
            }
        }
        return container.modelContainer
    }
}
