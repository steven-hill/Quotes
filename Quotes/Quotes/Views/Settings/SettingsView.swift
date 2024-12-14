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
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader(title: "NOTIFICATIONS")
                notificationContent
                sectionHeader(title: "APPEARANCE")
                appearanceContent
                Spacer()
                ZenQuotesAttributionView()
            }
            .navigationTitle("Settings")
            .padding(.top, 8)
            .padding(.horizontal)
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
    
    // MARK: - UI Components
    @ViewBuilder
    private var notificationContent: some View {
        if localNotificationManager.authorizationGranted {
            AuthorizationGrantedView()
        } else {
            AuthorizationNotGrantedView()
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
    
    private var appearanceContent: some View {
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
