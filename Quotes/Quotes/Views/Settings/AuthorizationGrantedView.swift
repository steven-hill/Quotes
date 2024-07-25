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
                Text("If you'd like to change the time you receive it, select another time below and tap 'Confirm':")
            }
            .font(.title3)
            .minimumScaleFactor(0.5)
            
            DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .padding(.trailing)
                .onChange(of: notificationTime) {
                    isDisabled = false
                }
            Button("Confirm") {
                Task {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
                    print(components.hour!)
                    print(components.minute!)
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
