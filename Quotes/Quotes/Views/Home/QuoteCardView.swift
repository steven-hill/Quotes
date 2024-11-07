//
//  QuoteCardView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct QuoteCardView: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State var showCard = false
    @State var offset: CGFloat = -UIScreen.main.bounds.height
    
    // MARK: - Constants
    let quoteContent: String
    let quoteAuthor: String
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "quote.opening")
                Spacer()
            }
            
            Text(quoteContent)
                .minimumScaleFactor(0.5)
                .padding([.leading, .trailing])
                .font(.title)
            
            HStack {
                Spacer()
                Image(systemName: "quote.closing")
            }
            .padding(.bottom)
            
            Text(quoteAuthor)
                .font(.title2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(quoteContent). End quote. \(quoteAuthor)")
        .padding(.all)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .light ? .black.opacity(0.1) : .gray)
                .stroke(.primary, lineWidth: 2)
        }
        .padding()
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? Constants.iPad.viewWidth : .infinity)
        .offset(y: offset)
        .rotation3DEffect(.init(degrees: showCard ? 0 : 180), axis: (x: showCard ? 0 : 1.0, y: 0, z: 0))
        .onAppear(perform: {
            showCard.toggle()
            offset = 0
        })
        .animation(.smooth(duration: 1), value: showCard)
        .onDisappear(perform: {
            showCard = false
        })
    }
    
    // MARK: - UI components
}

#Preview {
    QuoteCardView(quoteContent: "A man is great not because he hasn't failed; a man is great because failure hasn't stopped him.", quoteAuthor: "Confucius")
}
