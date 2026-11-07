//
//  AppCoordinator.swift
//  Quotes
//
//  Created by Steven Hill on 07/11/2026.
//

import Foundation

/// Handles navigation.
struct AppCoordinator {
    
    // MARK: - Dependency
    private let urlHandler: URLOpening
    
    // MARK: - Init
    init(urlHandler: URLOpening) {
        self.urlHandler = urlHandler
    }
    
    // MARK: - Method
    func openSettingsApp() {}
}
