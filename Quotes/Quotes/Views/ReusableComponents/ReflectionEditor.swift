//
//  ReflectionEditor.swift
//  Quotes
//
//  Created by Steven Hill on 03/01/2025.
//

import SwiftUI

struct ReflectionEditor: View {
    @Binding var text: String
    let accessibilityLabel: String
    private let placeholderText: String = "What are your thoughts on today's quote?"
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .accessibilityLabel(accessibilityLabel)
                .foregroundStyle(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.primary, lineWidth: 2)
                        .purpleGradientBackgroundModifier()
                )
                .scrollDismissesKeyboard(.immediately)
            
            if text.isEmpty {
                Text(placeholderText)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
                    .padding(.leading, 10)
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = "User's thoughts go here."
    ReflectionEditor(text: $text, accessibilityLabel: "Edit your thoughts.")
}
