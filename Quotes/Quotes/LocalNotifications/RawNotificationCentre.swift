//
//  RawNotificationCentre.swift
//  Quotes
//
//  Created by Steven Hill on 06/10/2026.
//

import UserNotifications

/// Abstraction mirroring Apple's `UNUserNotificationCenter`.
/// Wraps Apple’s concrete `UNUserNotificationCenter.current()`.
protocol RawNotificationCentre {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func fetchCurrentStatus() async -> NotificationPermissionStatus
    func add(_ request: UNNotificationRequest) async throws
    func removeAllPendingNotificationRequests()
}

// Make Apple's concrete class conform to it.
extension UNUserNotificationCenter: RawNotificationCentre {}
