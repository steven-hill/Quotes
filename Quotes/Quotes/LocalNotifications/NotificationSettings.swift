//
//  NotificationSettings.swift
//  Quotes
//
//  Created by Steven Hill on 30/04/2025.
//

import Foundation

enum AuthorizationStatus {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

// MARK: - Abstraction for notification settings.
struct NotificationSettings {
    let authorizationStatus: AuthorizationStatus
}
