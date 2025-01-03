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
    
    // MARK: - Body
    var body: some View {
        TabView() {
            QuoteOfTheDayView(quoteOfTheDayVM: QuoteViewModel(quoteService: QuoteService(cacheManager: CacheManager())))
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            SavedView(fetched: FetchRequestStore(managedObjectContext: managedObjectContext))
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
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
