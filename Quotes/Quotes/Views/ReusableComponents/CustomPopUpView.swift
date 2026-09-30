//
//  CustomPopUpView.swift
//  Quotes
//
//  Created by Steven Hill on 10/01/2025.
//

import SwiftUI

struct CustomPopUpView: View {
    
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Dependencies
    let message: String
    
    // MARK: - Body
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
            Text(message)
        }
        .font(.headline)
        .padding()
        .background(colorScheme == .light ? .white : .black)
        .foregroundColor(.green)
        .cornerRadius(10)
    }
}

#Preview {
    CustomPopUpView(message: "Saved")
    CustomPopUpView(message: "Edit saved")
    CustomPopUpView(message: "New time set")
}
