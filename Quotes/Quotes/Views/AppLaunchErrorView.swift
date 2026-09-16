//
//  AppLaunchErrorView.swift
//  Quotes
//
//  Created by Steven Hill on 16/09/2026.
//

import SwiftUI
import SwiftData

struct AppLaunchErrorView: View {

    //MARK: - Property
    let error: AppContainerError
    
    //MARK: - Initialisation
    init(error: AppContainerError) {
        self.error = error
    }
    
    //MARK: - Body
    var body: some View {
        ContentUnavailableView {
            Label(
                "\(error.localizedDescription)",
                systemImage: "exclamationmark.triangle"
            )
        } description: {
            Text("\(error.recoveryMessage)")
        }
    }
}

#Preview {
    AppLaunchErrorView(error: AppContainerError.failedToInitialiseStorage(error: SwiftDataError.unknownSchema))
}
