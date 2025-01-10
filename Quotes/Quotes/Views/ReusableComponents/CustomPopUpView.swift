//
//  CustomPopUpView.swift
//  Quotes
//
//  Created by Steven Hill on 10/01/2025.
//

import SwiftUI

struct CustomPopUpView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
            Text(message)
        }
        .font(.headline)
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

#Preview {
    CustomPopUpView(message: "Saved successfully!")
    CustomPopUpView(message: "Set successfully!")
}
