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
    @StateObject var appearanceManager = AppearanceManager()
    @StateObject var tabRouter = TabRouter()
    
    // MARK: - Constant
    let persistenceController = PersistenceController.shared
    
    // MARK: - Init
    init() {
        let managedObjectContext = persistenceController.container.viewContext
        let savedQuotesController = NSFetchedResultsController(fetchRequest: persistenceController.savedQuotesFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let store = FetchRequestStore(savedQuotesController: savedQuotesController, context: managedObjectContext)
        self._fetchRequestStore = StateObject(wrappedValue: store)
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environmentObject(fetchRequestStore)
                .environmentObject(localNotificationManager)
                .environmentObject(appearanceManager)
                .environmentObject(tabRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear() {
                    appearanceManager.overrideDisplayMode()
                }
                .onChange(of: appearanceManager.selectedAppearance) { _, newValue in
                    appearanceManager.setAppearance(newValue)
                    appearanceManager.overrideDisplayMode()
                }
        }
    }
}
