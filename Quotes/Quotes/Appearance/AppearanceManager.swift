//
//  AppearanceManager.swift
//  Quotes
//
//  Created by Steven Hill on 13/12/2024.
//

import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: .none
        case .light: .light
        case .dark: .dark
        }
    }
}

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
