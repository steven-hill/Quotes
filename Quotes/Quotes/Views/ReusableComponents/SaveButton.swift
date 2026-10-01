//
//  SaveButton.swift
//  Quotes
//
//  Created by Steven Hill on 06/01/2025.
//

import SwiftUI

struct SaveButton: View {
    
    //MARK: - Dependencies
    let accessibilityLabel: String
    let accessibilityHint: String
    let saveAction: () -> Bool
    let onCompletion: () -> Void
    
    //MARK: - Body
    var body: some View {
        Button("Save") {
            let isSuccess = saveAction()
            if isSuccess {
                onCompletion()
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

#Preview {
    SaveButton(
        accessibilityLabel: "Save quote with your reflection",
        accessibilityHint: "Saves your thoughts and returns to the previous screen.",
        saveAction: { true },
        onCompletion: {}
    )
}
