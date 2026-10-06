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
    private let center: RawNotificationCentre
    
    //MARK: - Initialisation
    /// Initializes the engine, defaulting to the system singleton.
    init(center: RawNotificationCentre = UNUserNotificationCenter.current()) {
        self.center = center
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }
}

