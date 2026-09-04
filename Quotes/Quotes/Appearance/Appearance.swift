//
//  Appearance.swift
//  Quotes
//
//  Created by Steven Hill on 04/09/2026.
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
