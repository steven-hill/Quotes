//
//  TabBar.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct TabBar: View {
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Environment Objects
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @EnvironmentObject var tabRouter: TabRouter
    
    // MARK: - State
    @State private var selectedTab: Tab = .home
    @State private var showLocalDatabaseFailureAlert = false
    
    //MARK: - Property
    /// Flags persistent storage issue.
    let isStorageDegraded: Bool

    // MARK: - Tab Definition
    private enum Tab {
        case home
        case saved
        case settings
    }
    
    //MARK: - Dependency
    private let factory: ViewFactory
    
    //MARK: - Initialisation
    init(
        factory: ViewFactory,
        isStorageDegraded: Bool
    ) {
        self.factory = factory
        self.isStorageDegraded = isStorageDegraded
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            factory.makeQuoteOfTheDayView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == .home ? .fill : .none)
                }
                .onAppear { selectedTab = .home }
                .tag(Tab.home)
            
            factory.makeSavedView()
                .tabItem {
                    Label("Saved", systemImage: selectedTab == .saved ? "bookmark.fill" : "bookmark")
                        .environment(\.symbolVariants, selectedTab == .saved ? .fill : .none)
                }
                .onAppear { selectedTab = .saved }
                .tag(Tab.saved)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: selectedTab == .settings ? "gearshape.circle.fill" : "gearshape.circle")
                        .environment(\.symbolVariants, selectedTab == .settings ? .fill : .none)
                }
                .onAppear { selectedTab = .settings }
                .tag(Tab.settings)
        }
        .tint(.primary)
        .task {
            try? await localNotificationManager.requestAuthorization()
        }
        .task {
            localNotificationManager.setUpNotificationTabRouter(tabRouter: tabRouter)
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                localNotificationManager.setBadgeCountToZero()
            }
        }
        .onChange(of: tabRouter.tabToBeShown) { _, newValue in
            if newValue == .home {
                selectedTab = .home
            }
        }
        .onAppear {
            if isStorageDegraded {
                showLocalDatabaseFailureAlert = true
            }
        }
        .alert(
            "Database failure",
            isPresented: $showLocalDatabaseFailureAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can continue to use the app but your changes will not be saved between app launches. If device storage is low, try to free up some space and restart the app. If the problem persists, try reinstalling the app.")
        }
    }
}

#Preview {
    TabBar(
        factory: ViewFactory(
            dependencies: try! AppContainer(isInMemoryOnly: true)
        ),
        isStorageDegraded: false
    )
        .environmentObject(LocalNotificationManager())
        .environmentObject(AppearanceManager())
        .environmentObject(TabRouter())
}
