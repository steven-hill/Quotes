//
//  AppearanceManager.swift
//  Quotes
//
//  Created by Steven Hill on 13/12/2024.
//

import SwiftUI

protocol UserDefaultsProviding {
    func integer(forKey defaultName: String) -> Int
    func set(_ value: Int, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProviding {}

enum Appearance: Int {
    case unspecified
    case light
    case dark
}

final class AppearanceManager: ObservableObject {
    @AppStorage private var selectedAppearance: Appearance
    
    init(store: UserDefaults = .standard) {
        _selectedAppearance = AppStorage(wrappedValue: .unspecified, "selectedAppearance", store: store)
    }
    
    func setAppearance(_ appearance: Appearance) {
        selectedAppearance = appearance
    }
}
