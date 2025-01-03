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

//#Preview {
//    StatefulPreviewWrapper("") { userThoughts in
//        ReflectionEditor as! AnyView(
//                    text: userThoughts,
//                    accessibilityLabel: "What are your thoughts on today's quote?"
//                )
//                //.previewLayout(.sizeThatFits) // Adjust the layout to fit content
//            }
//}
//
//struct StatefulPreviewWrapper<T>: View {
//    @State var value: T
//    let content: (Binding<T>) -> AnyView
//
//    init(_ initialValue: T, @ViewBuilder content: @escaping (Binding<T>) -> AnyView) {
//        _value = State(initialValue: initialValue)
//        self.content = content
//    }
//
//    var body: some View {
//        content($value)
//    }
//}
