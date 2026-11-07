//
//  UIApplicationURLHandler.swift
//  Quotes
//
//  Created by Steven Hill on 07/11/2026.
//

import Foundation
import UIKit

protocol URLOpening {
    func open(_ url: URL)
}

/// Used to open the device's Settings app from `SettingsView`.
final class UIApplicationURLHandler: URLOpening {

    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
