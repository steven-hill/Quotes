//
//  AuthorizationGrantedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct AuthorizationGrantedView: View {
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var notificationTime = Date.now
    @State private var isDisabled = true
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Each day has a new quote. We'll send you a notification at 10am to ensure you don't miss it.")
                Text("If you prefer a different time, select it below and tap 'Confirm'.")
            }
            .font(.title3)
            .minimumScaleFactor(0.5)
            
            DatePicker("I'd rather receive it at:", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .padding([.leading, .trailing])
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Time picker. Button. Activate to choose a different time.")
                .onChange(of: notificationTime) {
                    isDisabled = false
                }
            Button("Confirm") {
                Task {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
                    try await localNotificationManager.scheduleUserChosenNotificationTime(userChosenNotificationHour: components.hour ?? 10, userChosenNotificationMinute: components.minute ?? 00)
                }
                isDisabled = true
            }
            .disabled(isDisabled)
            .buttonStyle(.borderedProminent)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.viewWidth : .infinity)
    }
}

#Preview {
    AuthorizationGrantedView()
}
