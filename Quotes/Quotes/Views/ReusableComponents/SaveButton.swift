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
    }
}

#Preview {
    SaveButton(
        accessibilityLabel: "Save quote with your reflection",
        saveAction: { true },
        onCompletion: {}
    )
}
