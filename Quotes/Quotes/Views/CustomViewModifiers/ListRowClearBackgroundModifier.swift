//
//  ListRowClearBackgroundModifier.swift
//  Quotes
//
//  Created by Steven Hill on 06/03/2025.
//

import SwiftUI

struct ListRowClearBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
    }
}

extension View {
    func listRowClearBackgroundModifier() -> some View {
        self.modifier(ListRowClearBackgroundModifier())
    }
}

#Preview {
    Text("Hello, World!")
        .listRowClearBackgroundModifier()
}
