//
//  NotificationCenterWrapper.swift
//  Quotes
//
//  Created by Steven Hill on 27/12/2024.
//

import Foundation
import NotificationCenter
import UserNotifications

final class NotificationCenterWrapper: NSObject, NotificationCenterProtocol, UNUserNotificationCenterDelegate {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var tabRouter: TabRouter?
    
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
    
    func setBadgeCountToZero() {
        notificationCenter.setBadgeCount(0)
    }
    
    func setup(tabRouter: TabRouter) {
        self.tabRouter = tabRouter
        notificationCenter.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await handleNotificationTap()
    }
    
    @MainActor
    func handleNotificationTap() async {
        self.tabRouter?.tabToBeShown = .home
    }
}
