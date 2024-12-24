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
    @Published var selectedAppearance: Appearance
    private let userDefaults: UserDefaultsProviding
    private let windowProvider: WindowProviding
    
    init(userDefaults: UserDefaultsProviding = UserDefaults.standard, windowProvider: WindowProviding = DefaultWindowProvider()) {
        self.userDefaults = userDefaults
        self.windowProvider = windowProvider
        self.selectedAppearance = Appearance(rawValue: userDefaults.integer(forKey: "selectedAppearance")) ?? .unspecified
    }
    
    func overrideDisplayMode() {
        guard let window = windowProvider.currentWindow() else { return }
        window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: selectedAppearance.rawValue) ?? .unspecified
    }
    
    func setAppearance(_ appearance: Appearance) {
        selectedAppearance = appearance
        userDefaults.set(appearance.rawValue, forKey: "selectedAppearance")
    }
}
