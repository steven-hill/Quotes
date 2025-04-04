//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

@main
struct QuotesApp: App {
    
    // MARK: - State objects
    @StateObject var localNotificationManager = LocalNotificationManager()
    @StateObject var fetchRequestStore: FetchRequestStore
    @StateObject var appearanceManager = AppearanceManager()
    
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
                .environmentObject(localNotificationManager)
                .environmentObject(appearanceManager)
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
