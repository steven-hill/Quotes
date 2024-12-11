//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

@main
struct QuotesApp: App {
    
    // MARK: - State object
    @StateObject var viewModel = QuoteViewModel(quoteService: QuoteService(cacheManager: CacheManager()))
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var fetchRequestStore: FetchRequestStore
    
    // MARK: - Constant
    let persistenceController = PersistenceController.shared
    
    // MARK: - Init
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let store = FetchRequestStore(managedObjectContext: managedObjectContext)
        self._fetchRequestStore = StateObject(wrappedValue: store)
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environmentObject(viewModel)
                .environmentObject(localNotificationManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
