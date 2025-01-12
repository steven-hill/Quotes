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
    @State private var saveIsSuccessful = false
    
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
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.buttonWidth : .infinity)
        .background(colorScheme == .light ? .black.opacity(0.1) : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .sheet(isPresented: $reflectionSheetIsPresented) {
            ReflectOnQuoteView(userThoughts: userThoughts, quoteContent: quoteContent, quoteAuthor: quoteAuthor, successfulSave: {
                withAnimation(.spring().delay(0.25)) {
                    saveIsSuccessful.toggle()
                }
            })
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if saveIsSuccessful {
                CustomPopUpView(message: "Saved successfully!")
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring()) {
                                saveIsSuccessful.toggle()
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ReflectOnThisQuoteButton(quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
