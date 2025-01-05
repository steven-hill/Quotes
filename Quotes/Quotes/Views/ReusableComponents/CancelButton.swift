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
    
    // MARK: - Constant
    let accessibilityLabel: String
    
    // MARK: - Body
    var body: some View {
        Button("Cancel") {
            dismiss()
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    CancelButton(accessibilityLabel: "Cancel reflection and don't save.")
}

