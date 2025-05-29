//
//  MockNotificationTimeUserDefaults.swift
//  QuotesTests
//
//  Created by Steven Hill on 29/05/2025.
//

import Foundation
@testable import Quotes

final class MockNotificationTimeUserDefaults: NotificationTimeProtocol {
    private var mockNotificationTime: [String: String] = [:]
    
    func getNotificationTime(forKey: String) -> String {
        return mockNotificationTime[forKey] ?? "10:00"
    }
    
    func updateNotificationTime(to: String, forKey: String) {
        mockNotificationTime[forKey] = to
    }
}
