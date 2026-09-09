//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI
import CoreData

@main
struct QuotesApp: App {
    
    // MARK: - State objects
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var fetchRequestStore: FetchRequestStore
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject var tabRouter = TabRouter()
    
    //MARK: - Dependencies
    private let networkClient = NetworkClient()
    private let persistenceController = PersistenceController.shared
    
    // MARK: - Initialisation
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let savedQuotesController = NSFetchedResultsController(fetchRequest: persistenceController.savedQuotesFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let store = FetchRequestStore(savedQuotesController: savedQuotesController, context: managedObjectContext)
        self._fetchRequestStore = StateObject(wrappedValue: store)
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            TabBar(networkClient: networkClient)
                .environmentObject(fetchRequestStore)
                .environmentObject(localNotificationManager)
                .environmentObject(appearanceManager)
                .environmentObject(tabRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(appearanceManager.selectedAppearance.colorScheme)
        }
    }
}
