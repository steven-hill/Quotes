//
//  DefaultWindowProvider.swift
//  Quotes
//
//  Created by Steven Hill on 24/12/2024.
//

import SwiftUI

protocol WindowProviding {
    func currentWindow() -> UIWindow?
}

final class DefaultWindowProvider: WindowProviding {
    func currentWindow() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
}
