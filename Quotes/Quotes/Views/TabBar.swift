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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // MARK: - Environment Object
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    
    // MARK: - State
    @State private var selectedTab: Int = 0
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            QuoteOfTheDayView(quoteOfTheDayVM: QuoteViewModel(quoteService: QuoteService(cacheManager: CacheManager())))
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                }
                .onAppear { selectedTab = 0 }
                .tag(0)
            
            SavedView(fetched: FetchRequestStore(managedObjectContext: managedObjectContext))
                .tabItem {
                    Label("Saved", systemImage: selectedTab == 1 ? "bookmark.fill" : "bookmark")
                        .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: selectedTab == 2 ? "gearshape.circle.fill" : "gearshape.circle")
                        .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                }
                .onAppear { selectedTab = 2 }
                .tag(2)
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
        .environmentObject(LocalNotificationManager())
        .environmentObject(AppearanceManager())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
