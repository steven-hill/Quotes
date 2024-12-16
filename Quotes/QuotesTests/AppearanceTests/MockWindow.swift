//
//  MockWindow.swift
//  QuotesTests
//
//  Created by Steven Hill on 16/12/2024.
//

import SwiftUI

class MockWindow: UIWindow {
    var overriddenStyle: UIUserInterfaceStyle?

    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        get { overriddenStyle ?? .unspecified }
        set { overriddenStyle = newValue }
    }
}
