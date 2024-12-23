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
    private let windowProvider: () -> UIWindow?
    
    init(userDefaults: UserDefaultsProviding = UserDefaults.standard, windowProvider: @escaping () -> UIWindow? = defaultWindowProvider) {
        self.userDefaults = userDefaults
        self.windowProvider = windowProvider
        self.selectedAppearance = Appearance(rawValue: userDefaults.integer(forKey: "selectedAppearance")) ?? .unspecified
    }
    
    private static func defaultWindowProvider() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
    
    func overrideDisplayMode() {
        guard let window = windowProvider() else { return }
        window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: selectedAppearance.rawValue) ?? .unspecified
    }
    
    func setAppearance(_ appearance: Appearance) {
        selectedAppearance = appearance
        userDefaults.set(appearance.rawValue, forKey: "selectedAppearance")
    }
}
