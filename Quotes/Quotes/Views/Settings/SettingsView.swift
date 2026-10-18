//
//  SettingsView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct SettingsView: View {

    // MARK: - Environment
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - State
    @State private var settingsVM: SettingsViewModel
    @State private var isShowingTimePicker = false

    // MARK: - Bindable
    @Bindable private var appearanceManager: AppearanceManager

    // MARK: - Initialisation
    init(
        appearanceManager: AppearanceManager,
        localNotificationsManager: LocalNotificationsManager
    ) {
        self.appearanceManager = appearanceManager
        _settingsVM = State(
            initialValue: SettingsViewModel(
                localNotificationsManager: localNotificationsManager
            )
        )
    }

    // MARK: - Body
    var body: some View {
        @Bindable var bindableVM = settingsVM

        NavigationStack {
            Form {
                notificationSection()
                AppearanceSection(appearanceManager: appearanceManager)
                AttributionSection()
            }
            .alert(
                "Error",
                isPresented: $settingsVM.isShowingAlert,
                presenting: settingsVM.alertMessage
            ) { _ in
                Button("OK") {}
            } message: { message in
                Text(message)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .pinkBluePurpleBackgroundModifier()
        }
        .onAppear {
            settingsVM.syncUIState()
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task {
                await settingsVM.localNotificationsManager.updatePermissionState()
                settingsVM.syncUIState()
            }
        }
        .sheet(isPresented: $isShowingTimePicker) {
            TimePickerSheet(
                notificationTime: $bindableVM.notificationTime,
                onConfirm: {
                    Task { await settingsVM.setNewNotificationTime() }
                }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Notification Section
    @ViewBuilder
    private func notificationSection() -> some View {
        switch settingsVM.uiState {
        case .notConfigured:
            NotificationNotConfiguredSection {
                    Task { await settingsVM.requestPermissionAndSchedule() }
                }

        case .denied:
            NotificationDeniedSection()

        case .authorised(let time):
            NotificationAuthorisedSection(
                time: time,
                onChangeTime: { isShowingTimePicker = true }
            )
        }
    }
}

// MARK: - Notification Not Configured
private struct NotificationNotConfiguredSection: View {
    let onEnable: () -> Void

    var body: some View {
        Section("Notifications") {
            HStack {
                Text("Permission")
                Spacer()
                Button(
                    "Enable",
                    action: onEnable
                )
            }
        }
    }
}

// MARK: - Notification Denied
private struct NotificationDeniedSection: View {
    var body: some View {
        Section("Permissions") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notifications are Disabled")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(
                    "Each day has a new quote. Turn on notifications to ensure you don't miss it."
                )
                .font(.caption)
                .foregroundStyle(.gray)
                Button("Open System Settings") {
                    // TODO: Deep link to the Settings app.
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Notification Authorised
private struct NotificationAuthorisedSection: View {
    let time: String
    let onChangeTime: () -> Void

    var body: some View {
        Section("Notifications") {
            HStack {
                Text("Daily")
                Spacer()

                Text("Sent at \(time)")
                    .foregroundStyle(.green)
            }
            Button(action: onChangeTime) {
                HStack {
                    Text("Change Time")
                        .foregroundStyle(.link)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Appearance
private struct AppearanceSection: View {
    @Bindable var appearanceManager: AppearanceManager

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker(
                "Set to:",
                selection: $appearanceManager.selectedAppearance
            ) {
                ForEach(Appearance.allCases) { appearance in
                    Text(appearance.title)
                        .tag(appearance)
                }
            }
            .pickerStyle(.inline)
            .font(.title3)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Select appearance mode")
            .accessibilityHint("System, light, or dark appearance")
        }
        .listRowClearBackgroundModifier()
    }
}

// MARK: - Attribution
private struct AttributionSection: View {
    var body: some View {
        Section(header: Text("Attribution")) {
            ZenQuotesAttributionView()
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
