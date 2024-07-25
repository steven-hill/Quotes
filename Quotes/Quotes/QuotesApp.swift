//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

@main
struct QuotesApp: App {
    @StateObject var viewModel = QuoteViewModel(quoteService: QuoteService())
    
    @StateObject var localNotificationManager = LocalNotificationManager()
    
    let persistenceController = PersistenceController.shared
    
    @StateObject var fetchRequestStore: FetchRequestStore
    
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let store = FetchRequestStore(managedObjectContext: managedObjectContext)
        self._fetchRequestStore = StateObject(wrappedValue: store)
    }
    
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environmentObject(viewModel)
                .environmentObject(localNotificationManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
