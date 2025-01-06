//
//  SaveButton.swift
//  Quotes
//
//  Created by Steven Hill on 06/01/2025.
//

import SwiftUI

struct SaveButton: View {
    
    // MARK: - Save action
    let saveAction: () -> Void
    
    // MARK: - Accessibility
    let accessibilityLabel = "Save quote and reflection."
    
    // MARK: - Confirmation dialog
    let confirmationDialogTitle = "Tapped save button without text in editor."
    let showConfirmationDialog: Binding<Bool>
    let confirmationDialogActions: () -> [IdentifiableButton]
    let confirmationDialogMessage: String
    
    // MARK: - Alert
    let showAlert: Binding<Bool>
    let alertMessage: String
    
    // MARK: - Body
    var body: some View {
        Button("Save") {
            saveAction()
        }
        .accessibilityLabel(accessibilityLabel)
        .buttonStyle(.bordered)
        .confirmationDialog(confirmationDialogTitle, isPresented: showConfirmationDialog, titleVisibility: .hidden, actions: {
            ForEach(confirmationDialogActions()) { identifiableButton in
                identifiableButton.button
            }
        }, message: {
            Text(confirmationDialogMessage)
        })
        .alert("Save failed", isPresented: showAlert, presenting: alertMessage) { _ in
            Button("Ok") {}
        } message: { _ in
            Text("\(alertMessage). Please try again.")
        }
    }
}

// MARK: - Identifiable Button
struct IdentifiableButton: Identifiable {
    let id = UUID()
    let button: Button<Text>
}

#Preview {
    @Previewable @State var showConfirmationDialog: Bool = false
    @Previewable @State var showAlert: Bool = false
    let saveAction: () -> Void = {
        print("Saving reflection...")
    }
    let alertMessage = "An error occurred"
    
    SaveButton(saveAction: saveAction, showConfirmationDialog: $showConfirmationDialog, confirmationDialogActions: {
        [
            IdentifiableButton(button: Button(role: .destructive, action: { print("Discarding") }, label: { Text("Discard reflection") })),
            IdentifiableButton(button: Button(role: .cancel, action: { print("Canceling") }, label: { Text("Keep reflecting") }))
        ]
    }, confirmationDialogMessage: "This quote won't be saved if no reflection is added.", showAlert: $showAlert, alertMessage: alertMessage)
}
