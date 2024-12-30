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
    
    func notificationSettings() async -> UNNotificationSettings {
        return await notificationCenter.notificationSettings()
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        try await notificationCenter.add(request)
    }
    
    func removeAllPendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
