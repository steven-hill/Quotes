//
//  CardBackground.swift
//  Quotes
//
//  Created by Steven Hill on 21/12/2024.
//

import SwiftUI

struct CardBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(colorScheme == .light ? .black.opacity(0.1) : .gray.opacity(0.25))
                    .stroke(.primary, lineWidth: 2)
            )
    }
}

extension View {
    func cardBackgroundModifier() -> some View {
        self.modifier(CardBackgroundModifier())
    }
}

#Preview {
    Text("Hello, world!")
        .padding()
        .cardBackgroundModifier()
}
