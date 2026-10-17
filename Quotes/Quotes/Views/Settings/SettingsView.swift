//
//  SettingsView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Environment
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - State
    @State private var scheduleNotificationIsSuccessful = false
    @State private var settingsVM: SettingsViewModel
    
    // MARK: - Bindable
    @Bindable private var appearanceManager: AppearanceManager
    
    // MARK: - Initialisation
    init(
        appearanceManager: AppearanceManager,
        localNotificationsManager: LocalNotificationsManager
    ) {
        self.appearanceManager = appearanceManager
        _settingsVM = State(initialValue: SettingsViewModel(localNotificationsManager: localNotificationsManager))
    }
    
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
        .alert(
            "Error",
            isPresented: $settingsVM.isShowingAlert,
            presenting: settingsVM.alertMessage
        ) { _ in
            Button("Ok") {}
        } message: { _ in
            if let message = settingsVM.alertMessage  {
                Text(message)
            }
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
        if settingsVM.localNotificationsManager.isPermissionGranted {
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
        Picker(
            "Set to:",
            selection: $appearanceManager.selectedAppearance
        ) {
            ForEach(Appearance.allCases) { appearance in
                Text(appearance.title).tag(appearance)
            }
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
                await settingsVM.localNotificationsManager.updatePermissionState()
            }
        }
    }
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    SettingsView(
        appearanceManager: appContainer.appearanceManager,
        localNotificationsManager: appContainer.localNotificationsManager
    )
}
