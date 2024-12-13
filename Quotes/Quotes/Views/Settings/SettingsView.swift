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
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("NOTIFICATIONS")
                        .padding(.horizontal)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                content
                    .padding(.bottom, 16)
                HStack {
                    Text("APPEARANCE")
                        .padding(.horizontal)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack {
                    Text("Set appearance to:")
                        .padding(.horizontal)
                    Spacer()
                    Picker("Set appearance to", selection: $appearanceManager.selectedAppearance) {
                        Text("System").tag(Appearance.unspecified)
                        Text("Light").tag(Appearance.light)
                        Text("Dark").tag(Appearance.dark)
                    }
                }
                .font(.title3)
            }
            .navigationTitle("Settings")
            .padding(.top, 15)
            .padding(.horizontal)
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
        .environmentObject(AppearanceManager())
}
