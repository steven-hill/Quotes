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
    @State private var isShowingTimePicker = false
    
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
        @Bindable var bindableVM = settingsVM
        
        NavigationStack {
            Form {
                switch settingsVM.uiState {
                case .notConfigured:
                    Section("Notifications") {
                        HStack {
                            Text("Permission")
                            Spacer()
                            Button("Enable") {
                                Task { await settingsVM.requestPermissionAndSchedule() }
                            }
                        }
                    }
                case .denied:
                    Section("Permissions") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notifications are Disabled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Each day has a new quote. Turn on notifications to ensure you don't miss it.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button("Open System Settings") {
                                // TODO: - Deep link to Settings App
                            }
                            .buttonStyle(.borderedProminent)
                            // TODO: - Handle light & dark mode (.foregroundStyle(colorScheme == .dark ? .black : .white))
                            .padding(.top, 4)
                        }
                    }
                case .authorised(let time):
                    Section("Notifications") {
                        HStack {
                            Text("Daily")
                            Spacer()
                            Text("Sent at \(time)")
                                .foregroundColor(.green)
                        }
                        Button {
                            isShowingTimePicker = true
                        } label: {
                            HStack {
                                Text("Change Time")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $isShowingTimePicker) {
                            TimePickerSheet(
                                notificationTime: $bindableVM.notificationTime,
                                onConfirm: {
                                    Task { await settingsVM.setNewNotificationTime() }
                                })
                            .presentationDetents([.medium])
                        }
                    }
                }
            }
            .onAppear {
                settingsVM.syncUIState()
            }
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    Task {
                        await settingsVM.localNotificationsManager.updatePermissionState()
                        settingsVM.syncUIState()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .pinkBluePurpleBackgroundModifier()
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
}

#Preview {
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    SettingsView(
        appearanceManager: appContainer.appearanceManager,
        localNotificationsManager: appContainer.localNotificationsManager
    )
}
