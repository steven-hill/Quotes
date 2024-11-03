//
//  AuthorizationGrantedView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct AuthorizationGrantedView: View {
    
    // MARK: - Environment Object
    @EnvironmentObject private var localNotificationManager: LocalNotificationManager
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var notificationTime = Date.now
    @State private var isConfirmButtonDisabled = true
    
    // MARK: - Body
    var body: some View {
        VStack {
            notificationExplanationText
            timePicker
            confirmButton
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.viewWidth : .infinity)
    }
    
    // MARK: - UI Components
    private var notificationExplanationText: some View {
        VStack(alignment: .leading) {
            Text("Each day has a new quote. We'll send you a notification at 10am to ensure you don't miss it.")
            Text("If you prefer a different time, select it below and tap 'Confirm'.")
        }
        .font(.title3)
        .minimumScaleFactor(0.5)
    }
    
    private var timePicker: some View {
        DatePicker("I'd rather receive it at:", selection: $notificationTime, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .padding(.horizontal)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time picker. Button. Activate to choose a different time.")
            .onChange(of: notificationTime) {
                isConfirmButtonDisabled = false
        }
    }
    
    private var confirmButton: some View {
        Button("Confirm") {
            Task {
                let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
                try await localNotificationManager.scheduleUserChosenNotificationTime(userChosenNotificationHour: components.hour ?? 10, userChosenNotificationMinute: components.minute ?? 00)
            }
            isConfirmButtonDisabled = true
        }
        .disabled(isConfirmButtonDisabled)
        .buttonStyle(.borderedProminent)
        .foregroundStyle(colorScheme == .dark ? .black : .white)
    }
}

#Preview {
    AuthorizationGrantedView()
}
