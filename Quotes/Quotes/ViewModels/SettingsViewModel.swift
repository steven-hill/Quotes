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
    var alertMessage: String?
    var isShowingAlert = false
    
    // MARK: - Dependency
    let localNotificationsManager: NotificationService
    
    // MARK: - Initialisation
    init(localNotificationsManager: NotificationService) {
        self.localNotificationsManager = localNotificationsManager
        if let savedTime = parseTime(localNotificationsManager.scheduledTimeString) {
            notificationTime = savedTime
        } else {
            let defaultComponents = DateComponents(hour: 10, minute: 0)
            notificationTime = Calendar.current.date(from: defaultComponents) ?? .now
        }
    }
    
    // MARK: - Request Permission
    /// First-Time Setup.
    func requestPermissionAndSchedule() async {
        await localNotificationsManager.requestPermission()
        
        if localNotificationsManager.isPermissionGranted {
            await commitNotificationTime()
        } else if let serviceMessage = localNotificationsManager.alertMessage {
            self.alertMessage = serviceMessage
            self.isShowingAlert = true
        } else {
            self.alertMessage = "Something went wrong. Please try again."
            self.isShowingAlert = true
        }
    }
    
    private func commitNotificationTime() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        guard let hour = components.hour, let minute = components.minute else { return }
        
        do {
            try await localNotificationsManager.scheduleDailyNotification(
                hour: hour,
                minute: minute
            )
        } catch {
            self.alertMessage = "We couldn't save your notification time. Please try again."
            self.isShowingAlert = true
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
