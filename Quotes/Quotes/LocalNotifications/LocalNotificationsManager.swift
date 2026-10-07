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

protocol NotificationService {
    var isPermissionGranted: Bool { get }
    var alertMessage: String? { get set }
    var scheduledTimeString: String { get }
    
    func requestPermission() async
    func updatePermissionState() async
    func scheduleDailyNotification(hour: Int, minute: Int) async throws
    func clearAppBadge() async throws
}

@Observable
final class LocalNotificationsManager: NotificationService  {
    // MARK: - Dependencies
    private let engine: NotificationCentreEngine
    private let storage: UserDefaults
    
    // MARK: - Constants
    private static let timeStorageKey = "notificationTime"
    private static let staticReminderID = "daily_quote_notification"
    
    // MARK: - Observable State
    var isPermissionGranted = false
    var alertMessage: String?
    var scheduledTimeString = "10:00"
    
    // MARK: - Initialisation
    /// Initializes the manager, auto-loading any previously saved reminder configuration.
    init(
        engine: NotificationCentreEngine = LocalNotificationEngine(),
        storage: UserDefaults = .standard
    ) {
        self.engine = engine
        self.storage = storage
        if let storedTime = storage.string(forKey: Self.timeStorageKey) {
            self.scheduledTimeString = storedTime
        }
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
    
    /// Constructs, formats, and overwrites a repeating daily notification request.
    func scheduleDailyNotification(
        hour: Int,
        minute: Int
    ) async throws {
        guard (0...23).contains(hour), (0...59).contains(minute) else { return }
        engine.cancelAllPendingRequests()
        
        /// Payload details.
        let content = UNMutableNotificationContent()
        content.title = "Quotes"
        content.body = "Today's quote is ready for you!"
        content.sound = .default
        
        /// Define target daily delivery time.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        /// Create request overwriting the ID.
        let request = UNNotificationRequest(
            identifier: Self.staticReminderID,
            content: content,
            trigger: trigger
        )
        
        try await engine.schedule(request)
        
        /// Update state, and persist to `UserDefaults`.
        let formattedTime = String(
            format: "%02d:%02d",
            hour,
            minute
        )
        self.scheduledTimeString = formattedTime
        storage.set(
            formattedTime,
            forKey: Self.timeStorageKey
        )
    }
    
    /// Clears the app icon's notification badge count.
    func clearAppBadge() async throws {
        try await engine.resetBadge()
    }
}
