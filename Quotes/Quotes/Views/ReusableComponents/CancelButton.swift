//
//  CancelButton.swift
//  Quotes
//
//  Created by Steven Hill on 05/01/2025.
//

import SwiftUI

struct CancelButton: View {
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var showCancelAlert = false
    
    // MARK: - Constants
    let cancelAlertMessage = "Any changes will not be saved."
    let accessibilityLabel: String
    
    // MARK: - Body
    var body: some View {
        Button("Cancel") {
            showCancelAlert.toggle()
        }
        .alert("Cancel?", isPresented: $showCancelAlert) {
            Button("Cancel", role: .destructive) {
                dismiss()
            }
            Button("Stay here", role: .cancel) {}
        } message: {
            Text(cancelAlertMessage)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    CancelButton(accessibilityLabel: "Cancel reflection and don't save.")
}

