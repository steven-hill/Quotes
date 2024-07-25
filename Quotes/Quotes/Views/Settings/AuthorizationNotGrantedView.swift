//
//  AuthorizationNotGrantedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct AuthorizationNotGrantedView: View {
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    
    var body: some View {
        VStack {
            Text("Each day has a new quote. Turn on notifications to ensure you don't miss it.")
                .font(.title3)
                .padding()
            
            Button("Enable notifications", systemImage: "bell.badge.fill") {
                localNotificationManager.goToQuotesDemoInSettingsApp()
            }
            .buttonStyle(.automatic)
        }
    }
}

#Preview {
    AuthorizationNotGrantedView()
}
