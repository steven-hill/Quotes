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
            if newValue == .active {
                Task {
                    await localNotificationManager.getCurrentAuthorizationSetting()
                }
            }
        }
        .alert("Error", isPresented: $localNotificationManager.hasError, presenting: localNotificationManager.notificationError) { detail in
            Button("Ok") {}
        } message: { detail in
            Text(localNotificationManager.notificationError.errorDescription)
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
}

#Preview {
    SettingsView()
        .environmentObject(LocalNotificationManager())
}
