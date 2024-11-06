//
//  SettingsView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Environment Object
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Settings")
            Spacer()
            ZenQuotesAttributionView()
        }
        .onChange(of: scenePhase) { _, newValue in
            handleScenePhaseChange(newValue)
        }
        .alert("Error", isPresented: $localNotificationManager.hasError, presenting: localNotificationManager.notificationError) { _ in
            Button("Ok") {}
        } message: { detail in
            Text(detail.errorDescription)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if localNotificationManager.authorizationGranted {
            AuthorizationGrantedView()
        } else {
            AuthorizationNotGrantedView()
        }
    }
    
    // MARK: - Handle scene phase change function
    private func handleScenePhaseChange(_ newValue: ScenePhase) {
        if newValue == .active {
            Task {
                await localNotificationManager.getCurrentAuthorizationSetting()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocalNotificationManager())
}
