//
//  ViewFactory.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import SwiftUI

/// Manages `SwiftUI` presentation dependencies.
final class ViewFactory {
    
    //MARK: - Dependency
    private let dependencies: AppDependencyContaining
    
    //MARK: - Initialisation
    init(dependencies: AppDependencyContaining) {
        self.dependencies = dependencies
    }
    
    //MARK: - View Creation Method
    func makeQuoteOfTheDayView() -> some View {
        QuoteOfTheDayView(networkClient: dependencies.networkClient)
    }
}
