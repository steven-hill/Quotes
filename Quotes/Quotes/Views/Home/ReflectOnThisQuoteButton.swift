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
    
    //MARK: - Dependency
    private let factory: ViewFactory
    
    // MARK: - Properties
    let quoteContent: String
    let quoteAuthor: String
        
    // MARK: - Initialisation
    init(
        factory: ViewFactory,
        quoteContent: String,
        quoteAuthor: String
    ) {
        self.factory = factory
        self.quoteContent = quoteContent
        self.quoteAuthor = quoteAuthor
    }
    
    // MARK: - Body
    var body: some View {
        Button("Reflect", systemImage: "square.and.pencil") {
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
            factory.makeReflectOnQuoteView(
                quoteContent: quoteContent,
                quoteAuthor: quoteAuthor,
                successfulSave: {
                    withAnimation(.spring().delay(0.25)) {
                        saveIsSuccessful.toggle()
                    }
                }
            )
            .presentationDragIndicator(.visible)
        }
        .overlay {
            if saveIsSuccessful {
                CustomPopUpView(message: "Saved")
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
    let appContainer = try! AppContainer(isInMemoryOnly: true)
    let factory = ViewFactory(dependencies: appContainer)
    ReflectOnThisQuoteButton(
        factory: factory,
        quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.",
        quoteAuthor: "Confucius"
    )
}
