//
//  AppearanceManager.swift
//  Quotes
//
//  Created by Steven Hill on 13/12/2024.
//

import SwiftUI

@Observable
final class AppearanceManager {
    private let store: UserDefaults
    private let key = Constants.UserDefaultsAppearanceKey.key
    
    var selectedAppearance: Appearance {
        didSet {
            store.set(selectedAppearance.rawValue, forKey: key)
        }
    }
    
    init(store: UserDefaults = .standard) {
        self.store = store
        
        if let rawValue = store.string(forKey: key),
           let savedAppearance = Appearance(rawValue: rawValue) {
            self.selectedAppearance = savedAppearance
        } else {
            self.selectedAppearance = .system
        }
    }
}
