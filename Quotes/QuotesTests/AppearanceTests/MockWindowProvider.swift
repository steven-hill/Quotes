//
//  MockWindowProvider.swift
//  QuotesTests
//
//  Created by Steven Hill on 24/12/2024.
//

import SwiftUI
@testable import Quotes

class MockWindowProvider: WindowProviding {
    var mockWindow = UIWindow()
    
    func currentWindow() -> UIWindow? {
        return mockWindow
    }
}
