//
//  TimePickerSheet.swift
//  Quotes
//
//  Created by Steven Hill on 18/10/2026.
//

import SwiftUI

struct TimePickerSheet: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Binding
    @Binding var notificationTime: Date
    
    // MARK: - State
    @State private var tempTime = Date()
    
    // MARK: - Callback closure
    var onConfirm: () -> Void
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: $tempTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            }
            .onAppear { tempTime = notificationTime }
            .navigationTitle("Change Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        notificationTime = tempTime
                        onConfirm()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

#Preview {
    TimePickerSheet(
        notificationTime: .constant(Date()),
        onConfirm: {}
    )
}
