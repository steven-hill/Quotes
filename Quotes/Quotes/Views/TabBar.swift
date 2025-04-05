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
    @EnvironmentObject var fetchRequestStore: FetchRequestStore
    
    // MARK: - State
    @State private var selectedTab: Tab = .home

    private enum Tab {
        case home
        case saved
        case settings
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            QuoteOfTheDayView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == .home ? .fill : .none)
                }
                .onAppear { selectedTab = .home }
                .tag(Tab.home)
            
            SavedView()
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
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
    }
}

#Preview {
    TabBar()
        .environmentObject(FetchRequestStore(managedObjectContext: PersistenceController.preview.container.viewContext))
        .environmentObject(LocalNotificationManager())
        .environmentObject(AppearanceManager())
}
