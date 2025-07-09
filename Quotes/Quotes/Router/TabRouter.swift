//
//  TabRouter.swift
//  Quotes
//
//  Created by Steven Hill on 09/07/2025.
//

import Foundation

final class TabRouter: ObservableObject {
    enum Tab {
        case none, home
    }
    @Published var tabToBeShown: Tab = .none
}
