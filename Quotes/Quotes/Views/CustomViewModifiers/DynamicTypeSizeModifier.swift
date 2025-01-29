//
//  DynamicTypeSizeModifier.swift
//  Quotes
//
//  Created by Steven Hill on 29/01/2025.
//

import SwiftUI

struct DynamicTypeSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .accessibilityShowsLargeContentViewer()
    }
}

extension View {
    func dynamicTypeSizeModifier() -> some View {
        self.modifier(DynamicTypeSizeModifier())
    }
}

#Preview {
    Text("Hello, world!")
        .padding()
        .dynamicTypeSizeModifier()
}
