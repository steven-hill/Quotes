//
//  LocalNotificationsManager.swift
//  Quotes
//
//  Created by Steven Hill on 06/10/2026.
//

import UserNotifications

/// Responsible for interacting with the iOS notification subsystem
protocol NotificationCentreEngine {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func fetchStatus() async -> NotificationConfig
    func schedule(_ request: UNNotificationRequest) async throws
    func cancelAllPendingRequests()
    func resetBadge() async throws
}

/// Responsible for simple local state storage
protocol AppPreferencesStorage: Sendable {
    func string(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}

/// Storage engine using `UserDefaults.standard`.
struct PreferencesEngine: AppPreferencesStorage {
    func string(forKey key: String) -> String? { UserDefaults.standard.string(forKey: key) }
    func setString(
        _ value: String,
        forKey key: String
    ) { UserDefaults.standard.set(value, forKey: key) }
}

@Observable
final class LocalNotificationsManager {
    // MARK: - Dependencies
    private let engine: NotificationCentreEngine
    private let storage: AppPreferencesStorage
    
    // MARK: - Constants
    private static let timeStorageKey = "notificationTime"
    private static let defaultNotificationTime = "10:00"
    
    // MARK: - Observable State
    var isPermissionGranted = false
    var alertMessage: String?
    var scheduledTimeString = defaultNotificationTime
    
    // MARK: - Initialisation
    /// Initializes the manager, auto-loading any previously saved reminder configuration.
    init(
        engine: NotificationCentreEngine = LocalNotificationEngine(),
        storage: AppPreferencesStorage = PreferencesEngine()
    ) {
        self.engine = engine
        self.storage = storage
        self.scheduledTimeString = storage.string(forKey: LocalNotificationsManager.timeStorageKey) ?? LocalNotificationsManager.defaultNotificationTime
    }
    
    // MARK: - Methods
    /// Requests authorisation permissions from the user via the underlying engine wrapper.
    func requestPermission() async {
        do {
            let success = try await engine.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
            self.isPermissionGranted = success
            if !success {
                self.alertMessage = "Notification permissions were denied. Please enable them in the Settings app."
            }
        } catch {
            self.alertMessage = "An error occurred while requesting permission. Please try again."
        }
    }
    
    /// Refreshes the local observable state by fetching current settings.
    func updatePermissionState() async {
        let config = await engine.fetchStatus()
        // Captures both explicit approval and silent provisional.
        self.isPermissionGranted = (config.status == .authorized || config.status == .provisional)
    }
}
