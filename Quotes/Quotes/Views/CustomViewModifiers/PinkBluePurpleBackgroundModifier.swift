//
//  PinkBluePurpleBackgroundModifier.swift
//  Quotes
//
//  Created by Steven Hill on 06/03/2025.
//

import SwiftUI

struct PinkBluePurpleBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LinearGradient(colors: [.pink, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.25)
                .ignoresSafeArea())
    }
}

extension View {
    func pinkBluePurpleBackgroundModifier() -> some View {
        self.modifier(PinkBluePurpleBackgroundModifier())
    }
}

#Preview {
    Text("Hello, world!")
        .pinkBluePurpleBackgroundModifier()
}
