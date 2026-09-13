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
    let swiftDataQuoteRepository: QuoteRepository
    let networkClient: Networking
    private(set) var isRunningInDegradedMode = false
    private(set) var databaseErrorReason: String?
    
    // MARK: - Initialisation
    init(isInMemoryOnly: Bool = false) {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: isInMemoryOnly)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            self.swiftDataQuoteRepository = SwiftDataQuoteRepository(container: modelContainer)
        } catch {
            self.isRunningInDegradedMode = true
            self.databaseErrorReason = error.localizedDescription
            do {
                let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
                self.swiftDataQuoteRepository = SwiftDataQuoteRepository(container: modelContainer)
            } catch {
                fatalError("Failed to initialise SwiftData ModelContainer in degraded mode: \(error.localizedDescription)")
            }
        }
        self.networkClient = NetworkClient()
    }
}
