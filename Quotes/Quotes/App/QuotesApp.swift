//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

@main
struct QuotesApp: App {
    
    // MARK: - State Objects
    @StateObject private var localNotificationManager = LocalNotificationManager()
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var tabRouter = TabRouter()
    
    // MARK: - State
    @State private var appState: AppState = .loading
    @State private var hasInitialisedAppContainer = false
    
    //MARK: - AppState Definition
    private enum AppState {
        case loading
        case ready(
            factory: ViewFactory,
            isStorageDegraded: Bool
        )
        case failed(AppContainerError)
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            switch appState {
            case .loading:
                ProgressView()
                    .task { await triggerAppContainerInitialisation() }
            case .ready(let factory, let isStorageDegraded):
                TabBar(
                    factory: factory,
                    isStorageDegraded: isStorageDegraded,
                )
                    .environmentObject(localNotificationManager)
                    .environmentObject(appearanceManager)
                    .environmentObject(tabRouter)
                    .preferredColorScheme(appearanceManager.selectedAppearance.colorScheme)
            case .failed(let error):
                AppLaunchErrorView(error: error)
            }
        }
    }
    
    //MARK: - Helper Methods
    private func triggerAppContainerInitialisation() async {
        guard !hasInitialisedAppContainer else { return }
        hasInitialisedAppContainer = true
        await initialiseAppContainer()
    }
    
    nonisolated private func initialiseAppContainer() async {
        do {
            let container = try await AppContainer()
            await MainActor.run {
                let factory = ViewFactory(dependencies: container)
                appState = .ready(
                    factory: factory,
                    isStorageDegraded: container.isRunningInDegradedMode
                )
            }
        } catch let error as AppContainerError {
            await MainActor.run {
                appState = .failed(error)
            }
        } catch {
            await MainActor.run {
                appState = .failed(.failedToInitialiseStorage(error: error))
            }
        }
    }
}
