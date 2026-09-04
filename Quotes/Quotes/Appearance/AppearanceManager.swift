//
//  AppearanceManager.swift
//  Quotes
//
//  Created by Steven Hill on 13/12/2024.
//

import SwiftUI

final class AppearanceManager: ObservableObject {
    @AppStorage var selectedAppearance: Appearance
    
    init(store: UserDefaults = .standard) {
        _selectedAppearance = AppStorage(
            wrappedValue: .system,
            "selectedAppearance",
            store: store
        )
    }
}
