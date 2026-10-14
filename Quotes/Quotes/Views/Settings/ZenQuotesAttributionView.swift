//
//  ZenQuotesAttributionView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI
import WebKit

struct ZenQuotesAttributionView: View {
    
    // MARK: - State
    @State private var showWebView = false
    
    // MARK: - Body
    var body: some View {
        Button("Zen Quotes API") {
            showWebView = true
        }
        .foregroundStyle(.link)
        .sheet(isPresented: $showWebView) {
            NavigationStack {
                WebView(
                    url: URL(string: "https://www.zenquotes.io/")
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showWebView = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZenQuotesAttributionView()
}
