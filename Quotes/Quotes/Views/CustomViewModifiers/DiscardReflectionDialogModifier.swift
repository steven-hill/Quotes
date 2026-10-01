//
//  DiscardReflectionDialogModifier.swift
//  Quotes
//
//  Created by Steven Hill on 01/10/2026.
//

import SwiftUI

struct DiscardReflectionDialogModifier: ViewModifier {
    @Binding var isPresented: Bool
    let messageText: String
    let onDiscard: () -> Void
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Tapped save button without text in editor.",
                isPresented: $isPresented,
                titleVisibility: .hidden
            ) {
                Button(
                    "Discard reflection",
                    role: .destructive
                ) { onDiscard() }
                Button("Continue reflecting") {}
            } message: {
                Text(messageText)
            }
    }
}

extension View {
    func discardReflectionDialog(
        isPresented: Binding<Bool>,
        message: String,
        onDiscard: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DiscardReflectionDialogModifier(
                isPresented: isPresented,
                messageText: message,
                onDiscard: onDiscard
            )
        )
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var isShowingDialog = false
        
        var body: some View {
            Button("Trigger Dialog") {
                isShowingDialog = true
            }
            .discardReflectionDialog(
                isPresented: $isShowingDialog,
                message: "This quote won't be saved if no reflection is added."
            ) {}
        }
    }
    return PreviewContainer()
}
