//
//  QuotesApp.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

@main
struct QuotesApp: App {
    
    // MARK: - State Object
    @StateObject private var tabRouter = TabRouter()
    
    // MARK: - State
    @State private var appState: AppState = .loading
    @State private var hasInitialisedAppContainer = false
    
    //MARK: - AppState Definition
    private enum AppState {
        case loading
        case ready(
            factory: ViewFactory,
            appearanceManager: AppearanceManager,
            isStorageDegraded: Bool,
            localNotificationsManager: LocalNotificationsManager
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
            case .ready(
                let factory,
                let appearanceManager,
                let isStorageDegraded,
                let localNotificationsManager
            ):
                TabBar(
                    factory: factory,
                    isStorageDegraded: isStorageDegraded,
                )
                .environmentObject(tabRouter)
                .preferredColorScheme(appearanceManager.selectedAppearance.colorScheme)
                .task { await localNotificationsManager.updatePermissionState() }
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
                    appearanceManager: container.appearanceManager,
                    isStorageDegraded: container.isRunningInDegradedMode,
                    localNotificationsManager: container.localNotificationsManager
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
