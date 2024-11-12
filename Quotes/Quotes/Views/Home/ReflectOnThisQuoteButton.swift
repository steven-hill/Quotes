//
//  ReflectOnThisQuoteButton.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct ReflectOnThisQuoteButton: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var reflectionSheetIsPresented = false
    
    // MARK: - Constants
    let quoteContent: String
    let quoteAuthor: String
    let userThoughts: String = ""
    
    // MARK: - Body
    var body: some View {
        Button("Reflect on this quote", systemImage: "square.and.pencil") {
            reflectionSheetIsPresented.toggle()
        }
        .tint(.primary)
        .bold()
        .padding(.all)
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.buttonWidth : .infinity)
        .background(colorScheme == .light ? .black.opacity(0.1) : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .sheet(isPresented: $reflectionSheetIsPresented) {
            ReflectOnQuoteView(userThoughts: userThoughts, quoteContent: quoteContent, quoteAuthor: quoteAuthor)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ReflectOnThisQuoteButton(quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
