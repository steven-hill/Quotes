//
//  ViewFactory.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import Foundation

/// Manages `SwiftUI` presentation dependencies.
final class ViewFactory {
    private let dependencies: AppDependencyContaining
    
    init(dependencies: AppDependencyContaining) {
        self.dependencies = dependencies
    }
}
