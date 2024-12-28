//
//  UIApplicationWrapper.swift
//  Quotes
//
//  Created by Steven Hill on 28/12/2024.
//

import SwiftUI

class UIApplicationWrapper: ApplicationProtocol {
    private let application: UIApplication
    
    init(application: UIApplication = UIApplication.shared) {
        self.application = application
    }
    
    func canOpenURL(_ url: URL) -> Bool {
        return application.canOpenURL(url)
    }
    
    func open(_ url: URL) async {
        _ = await MainActor.run {
            Task {
                await self.application.open(url)
            }
        }
    }
}
