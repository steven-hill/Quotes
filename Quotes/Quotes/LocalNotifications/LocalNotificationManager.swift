//
//  LocalNotificationManager.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import NotificationCenter

protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws
    func notificationSettings() async -> UNNotificationSettings
    func add(_ request: UNNotificationRequest) async throws
    func removeAllPendingNotificationRequests()
}

protocol ApplicationProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL) async
}

@MainActor
final class LocalNotificationManager: ObservableObject {
    
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
    
    private let notificationCenter: NotificationCenterProtocol
    private let application: ApplicationProtocol
    @Published var authorizationGranted = false
    @Published var hasError: Bool = false
    @Published var notificationError: NotificationError = .none
    @Published var notificationTime = "10:00"
    private let badgeCount = 1
    private let notificationTitle = "Quotes"
    private let notificationBody = "Today's quote is available. Tap here to see it."
    var userChosenNotificationHour: Int?
    var userChosenNotificationMinute: Int?
    
    init(notificationCenter: NotificationCenterProtocol = NotificationCenterWrapper(),
         application: ApplicationProtocol = UIApplicationWrapper()) {
        self.notificationCenter = notificationCenter
        self.application = application
    }
    
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
        guard let url = URL(string: UIApplication.openSettingsURLString), application.canOpenURL(url) else { return }
        Task { await application.open(url) }
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
            notificationTime = String(format: "%02d:%02d", userChosenNotificationHour, userChosenNotificationMinute)
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
