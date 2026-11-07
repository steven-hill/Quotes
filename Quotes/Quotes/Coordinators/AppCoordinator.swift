//
//  AppCoordinator.swift
//  Quotes
//
//  Created by Steven Hill on 07/11/2026.
//

import Foundation
import UIKit

protocol AppCoordinating {
    func openSettingsApp()
}

/// Handles navigation.
struct AppCoordinator: AppCoordinating {
    
    // MARK: - Dependency
    private let urlHandler: URLOpening
    
    // MARK: - Init
    init(urlHandler: URLOpening) {
        self.urlHandler = urlHandler
    }
    
    // MARK: - Method
    func openSettingsApp() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        urlHandler.open(settingsURL)
    }
}
