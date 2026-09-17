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
    
    // MARK: - State Objects
    @StateObject private var localNotificationManager = LocalNotificationManager()
    @StateObject private var fetchRequestStore: FetchRequestStore
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var tabRouter = TabRouter()
    
    // MARK: - State
    @State private var appState: AppState = .loading
    @State private var hasInitialisedAppContainer = false
    
    //MARK: - AppState Definition
    private enum AppState {
        case loading
        case ready(AppContainer)
        case failed(AppContainerError)
    }
    
    //MARK: - Dependencies
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
            switch appState {
            case .loading:
                ProgressView()
                    .task { initialiseAppContainer() }
            case .ready(let container):
                TabBar(appContainer: container)
                    .environmentObject(fetchRequestStore)
                    .environmentObject(localNotificationManager)
                    .environmentObject(appearanceManager)
                    .environmentObject(tabRouter)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .preferredColorScheme(appearanceManager.selectedAppearance.colorScheme)
            case .failed(let error):
                AppLaunchErrorView(error: error)
            }
        }
    }
    
    //MARK: - Helper Method
    private func initialiseAppContainer() {
        guard !hasInitialisedAppContainer else { return }
        hasInitialisedAppContainer = true
        do {
            let container = try AppContainer()
            appState = .ready(container)
        } catch let error as AppContainerError {
            appState = .failed(error)
        } catch {
            appState = .failed(.failedToInitialiseStorage(error: error))
        }
    }
}
