//
//  NotificationPermissionStatus.swift
//  Quotes
//
//  Created by Steven Hill on 06/10/2026.
//

import Foundation

/// Domain representation of local notification authorisation states.
enum NotificationPermissionStatus: String {
    case notDetermined
    case denied
    case authorized
    case provisional
}

/// Lightweight container representing current notification preferences.
struct NotificationConfig: Sendable {
    let status: NotificationPermissionStatus
    
    init(status: NotificationPermissionStatus) {
        self.status = status
    }
}
