//
//  SettingsViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 07/10/2026.
//

import Foundation

@Observable
final class SettingsViewModel {
    
    //MARK: - Observable State
    var notificationTime = Date()
    
    // MARK: - Dependency
    let localNotificationsManager: LocalNotificationsManager
    
    // MARK: - Initialisation
    init(localNotificationsManager: LocalNotificationsManager) {
        self.localNotificationsManager = localNotificationsManager
        if let savedTime = parseTime(localNotificationsManager.scheduledTimeString) {
            notificationTime = savedTime
        } else {
            let defaultComponents = DateComponents(hour: 10, minute: 0)
            notificationTime = Calendar.current.date(from: defaultComponents) ?? .now
        }
    }
    
    // MARK: - Helper Method
    /// Formats an 24-hour time string ("HH:mm") into a concrete Date instance to drive the SwiftUI DatePicker.
    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Guarantees consistent formatting regardless of phone locale
        return formatter.date(from: timeString)
    }
}
