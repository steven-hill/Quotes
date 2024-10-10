//
//  LocalNotificationManager.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import NotificationCenter

@MainActor
class LocalNotificationManager: ObservableObject {
    
    enum NotificationError: Error, LocalizedError {
        case none
        case requestAuthorizationFailure
        case failedToSetNotificationTime
        
        var errorDescription: String {
            switch self {
            case .none:
                return ""
            case .requestAuthorizationFailure:
                return "Sorry, there was an error completing notification authorization. Please try again in Settings."
            case .failedToSetNotificationTime:
                return "Sorry, there was an error setting the notification time. Please try again."
            }
        }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    @Published var authorizationGranted = false
    @Published var hasError: Bool = false
    @Published var notificationError: NotificationError = .none
    private let badgeCount = 1
    private let notificationTitle = "Quotes"
    private let notificationBody = "Today's quote is available. Tap here to see it."
    var userChosenNotificationHour: Int?
    var userChosenNotificationMinute: Int?
    
    func requestAuthorization() async throws {
        do {
            try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
        } catch {
            self.hasError = true
            notificationError = .requestAuthorizationFailure
            throw NotificationError.requestAuthorizationFailure
        }
    }
    
    func getCurrentAuthorizationSetting() async {
        let currentSetting = await notificationCenter.notificationSettings()
        authorizationGranted = (currentSetting.authorizationStatus == .authorized)
    }
    
    func goToQuotesInSettingsApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
        Task { await UIApplication.shared.open(url) }
    }
    
    func scheduleUserChosenNotificationTime(userChosenNotificationHour: Int, userChosenNotificationMinute: Int) async throws {
        removeAnyPendingNotifications()
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = .default
        content.badge = (badgeCount) as NSNumber
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = userChosenNotificationHour
        dateComponents.minute = userChosenNotificationMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
        } catch {
            self.hasError = true
            notificationError = .failedToSetNotificationTime
            throw NotificationError.failedToSetNotificationTime
        }
    }
    
    func removeAnyPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
