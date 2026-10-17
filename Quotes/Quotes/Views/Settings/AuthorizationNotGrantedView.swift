//
//  AuthorizationNotGrantedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct AuthorizationNotGrantedView: View {
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    
    // MARK: - View Model
    var viewModel: SettingsViewModel
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text("Each day has a new quote. Turn on notifications to ensure you don't miss it.")
                .font(.title3)
                .padding(.bottom, 8)
            
            Button("Enable notifications", systemImage: "bell.badge.fill") {
                localNotificationManager.goToQuotesInSettingsApp()
            }
            .buttonStyle(.automatic)
        }
    }
}

#Preview {
    AuthorizationNotGrantedView(viewModel: SettingsViewModel(localNotificationsManager: LocalNotificationsManager()))
}
