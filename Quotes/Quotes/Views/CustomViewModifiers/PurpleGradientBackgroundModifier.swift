//
//  PurpleGradientBackgroundModifier.swift
//  Quotes
//
//  Created by Steven Hill on 06/03/2025.
//

import SwiftUI

struct PurpleGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(colors: [.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.25)
                .ignoresSafeArea())
    }
}

extension View {
    func purpleGradientBackgroundModifier() -> some View {
        self.modifier(PurpleGradientBackgroundModifier())
    }
}

#Preview {
    Text("Hello, world!")
        .purpleGradientBackgroundModifier()
}
