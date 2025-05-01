//
//  NotificationCenterWrapper.swift
//  Quotes
//
//  Created by Steven Hill on 27/12/2024.
//

import Foundation
import NotificationCenter

final class NotificationCenterWrapper: NotificationCenterProtocol {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws {
        try await notificationCenter.requestAuthorization(options: options)
    }
    
    func notificationSettings() async -> NotificationSettings {
        let settings = await notificationCenter.notificationSettings()
        let status: AuthorizationStatus
        switch settings.authorizationStatus {
            case .authorized: status = .authorized
            case .denied: status = .denied
            case .notDetermined: status = .notDetermined
            case .provisional: status = .provisional
            case .ephemeral: status = .ephemeral
            @unknown default: status = .notDetermined
        }
        return NotificationSettings(authorizationStatus: status)
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        try await notificationCenter.add(request)
    }
    
    func removeAllPendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
