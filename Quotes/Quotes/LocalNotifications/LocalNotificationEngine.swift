//
//  LocalNotificationEngine.swift
//  Quotes
//
//  Created by Steven Hill on 06/10/2026.
//

import Foundation
import UserNotifications

final class LocalNotificationEngine {
    
    //MARK: - Dependency
    private let centre: RawNotificationCentre
    
    //MARK: - Initialisation
    /// Initializes the engine, defaulting to the system singleton.
    init(centre: RawNotificationCentre = UNUserNotificationCenter.current()) {
        self.centre = centre
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await centre.requestAuthorization(options: options)
    }
    
    func fetchStatus() async -> NotificationConfig {
        let status = await centre.fetchCurrentStatus()
        return NotificationConfig(status: status)
    }
}

// MARK: - `UNUserNotificationCenter` Extension
extension UNUserNotificationCenter {
    func fetchCurrentStatus() async -> NotificationPermissionStatus {
        let settings = await self.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized: return .authorized
        case .provisional: return .provisional
        case .denied: return .denied
        default: return .notDetermined
        }
    }
}
