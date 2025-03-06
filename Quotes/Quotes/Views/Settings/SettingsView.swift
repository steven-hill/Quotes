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
    
    // MARK: - State
    @State private var scheduleNotificationIsSuccessful = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section(header: sectionHeader(title: "NOTIFICATIONS")) {
                    notificationContent
                }
                .listRowClearBackgroundModifier()
                Section(header: sectionHeader(title: "APPEARANCE")) {
                    appearanceContent
                }
                .listRowClearBackgroundModifier()
                Section(header: sectionHeader(title: "ATTRIBUTION")) {
                    ZenQuotesAttributionView()
                }
                .listRowClearBackgroundModifier()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .pinkBluePurpleBackgroundModifier()
        }
        .onChange(of: scenePhase) { _, newValue in
            handleScenePhaseChange(newValue)
        }
        .alert("Error", isPresented: $localNotificationManager.hasError, presenting: localNotificationManager.notificationError) { _ in
            Button("Ok") {}
        } message: { detail in
            Text(detail.errorDescription)
        }
        .overlay {
            if scheduleNotificationIsSuccessful {
                CustomPopUpView(message: "New time set")
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring()) {
                                scheduleNotificationIsSuccessful.toggle()
                            }
                        }
                    }
            }
        }
    }
    
    // MARK: - UI Components
    @ViewBuilder
    private var notificationContent: some View {
        if localNotificationManager.authorizationGranted {
            AuthorizationGrantedView(scheduleNotificationSuccess: {
                withAnimation(.spring().delay(0.25)) {
                    scheduleNotificationIsSuccessful.toggle()
                }
            })
        } else {
            AuthorizationNotGrantedView()
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .bold()
            .foregroundStyle(.secondary)
    }
    
    private var appearanceContent: some View {
        Picker("Set to:", selection: $appearanceManager.selectedAppearance) {
            Text("System").tag(Appearance.unspecified)
            Text("Light").tag(Appearance.light)
            Text("Dark").tag(Appearance.dark)
        }
        .pickerStyle(.inline)
        .font(.title3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Select appearance mode")
        .accessibilityHint("System, light, or dark appearance")
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
