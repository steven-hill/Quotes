//
//  NoSavedQuotesView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct NoSavedQuotesView: View {
    var body: some View {
        ContentUnavailableView("No saved quotes.", systemImage: "quote.bubble", description: Text("Quotes you reflect on and save will appear here."))
    }
}

#Preview {
    NoSavedQuotesView()
}
