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
    private let center: RawNotificationCenter
    
    //MARK: - Initialisation
    /// Initializes the engine, defaulting to the system singleton.
    init(center: RawNotificationCenter = UNUserNotificationCenter.current()) {
        self.center = center
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }
}

/// Abstraction mirroring Apple's `UNUserNotificationCenter`.
/// Wraps Apple’s concrete `UNUserNotificationCenter.current()`.
protocol RawNotificationCenter {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}

// Make Apple's concrete class conform to it.
extension UNUserNotificationCenter: RawNotificationCenter {}

