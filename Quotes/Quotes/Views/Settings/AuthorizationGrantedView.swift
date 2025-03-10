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
    
    // MARK: - Action
    let scheduleNotificationSuccess: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack {
            notificationExplanationText
            timePicker
                .lineLimit(nil)
                .fixedSize(horizontal: true, vertical: false)
                .padding([.bottom, .trailing], 18)
            confirmButton
        }
    }
    
    // MARK: - UI Components
    private var notificationExplanationText: some View {
        Text("Each day has a new quote. We'll send you a notification at \(localNotificationManager.notificationTime) to ensure you don't miss it. If you prefer a different time, select it below and tap 'Confirm'.")
            .font(.title3)
            .minimumScaleFactor(0.5)
    }
    
    private var timePicker: some View {
        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
            .datePickerStyle(.compact)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time picker. Button. Activate to choose a different time.")
            .onChange(of: notificationTime) {
                isConfirmButtonDisabled = false
        }
    }
    
    private var confirmButton: some View {
        Button("Confirm", action: scheduleNotification)
            .disabled(isConfirmButtonDisabled)
            .buttonStyle(.borderedProminent)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
    }
    
    // MARK: - Schedule notification function
    private func scheduleNotification() {
        Task {
            let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            try await localNotificationManager.scheduleUserChosenNotificationTime(userChosenNotificationHour: components.hour ?? 10, userChosenNotificationMinute: components.minute ?? 00)
            isConfirmButtonDisabled = true
            scheduleNotificationSuccess()
        }
    }
}

#Preview {
    AuthorizationGrantedView(scheduleNotificationSuccess: {})
        .environmentObject(LocalNotificationManager())
}
