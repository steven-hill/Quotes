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
    init(isInMemoryOnly: Bool = false) throws {
        self.networkClient = NetworkClient()
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: isInMemoryOnly)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            self.quoteRepository = SwiftDataQuoteRepository(container: modelContainer)
        } catch {
            #if DEBUG
            print("Persistent SwiftData store failed:", error)
            #endif
            do {
                let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
                self.quoteRepository = SwiftDataQuoteRepository(container: modelContainer)
                self.isRunningInDegradedMode = true
            } catch {
                #if DEBUG
                print("In-memory SwiftData store also failed:", error)
                #endif
                throw AppContainerError.failedToInitialiseStorage(error: error)
            }
        }
    }
    
    //MARK: - In-memory Model Container
    static func makePreviewContainer(withSampleData: Bool = true) -> ModelContainer {
        let container = try! AppContainer(isInMemoryOnly: true)
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
