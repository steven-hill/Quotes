//
//  NoSearchResultsFoundView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI

struct NoSearchResultsFoundView: View {
    @Binding var searchQuery: String
    
    var body: some View {
        ContentUnavailableView("No results found for '\(searchQuery)'", systemImage: "magnifyingglass", description: Text("Check the spelling or try a new search."))
    }
}

#Preview {
    NoSearchResultsFoundView(searchQuery: .constant("Something"))
}
