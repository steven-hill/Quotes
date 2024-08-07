//
//  SavedCardView.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import SwiftUI
import UIKit

struct SavedCardView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPopoverPresented = false
    @State private var isEditReflectionSheetPresented = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    let savedQuote: SavedQuote
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Menu {
                                Button {
                                    isPopoverPresented.toggle()
                                    presentActivityController()
                                } label: {
                                    Label("Share this quote", systemImage: "square.and.arrow.up")
                                }
                                Button("Edit your reflection", systemImage: "square.and.pencil") {
                                    isEditReflectionSheetPresented.toggle()
                                }
                                Button(role: .destructive) {
                                    do {
                                        try PersistenceController.shared.delete(savedQuote: savedQuote)
                                    } catch {
                                        print(error.localizedDescription)
                                        showAlert.toggle()
                                        alertMessage = PersistenceController.shared.persistenceError.localizedDescription
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } label: {
                                Label("", systemImage: "ellipsis.circle.fill")
                            }
                            .sheet(isPresented: $isEditReflectionSheetPresented) {
                                EditReflectionView(savedQuote: savedQuote, quoteContent: savedQuote.quoteContent ?? "Content unavailable", quoteAuthor: savedQuote.quoteAuthor ?? "Author name unavailable", userThoughts: savedQuote.reflection ?? "Reflection unavailable")
                                    .presentationDragIndicator(.visible)
                            }
                            .alert("Error", isPresented: $showAlert, presenting: alertMessage) { detail in
                                Button("Please try again") {}
                            } message: { detail in
                                Text(alertMessage)
                            }
                        }
                    }
                }
                HStack {
                    Image(systemName: "quote.opening")
                    Spacer()
                }
                Text(savedQuote.quoteContent ?? "Quote unavailable")
                    .minimumScaleFactor(0.5)
                    .padding([.leading, .trailing])
                    .font(.callout)
                HStack {
                    Spacer()
                    Image(systemName: "quote.closing")
                }
                Text(savedQuote.quoteAuthor ?? "Author name unavailable")
                    .font(.callout)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(colorScheme == .light ? .black.opacity(0.1) : .gray)
                    .stroke(.primary, lineWidth: 2)
            }
        }
    }
}

extension SavedCardView {
    func presentActivityController() {
        var quoteToShare: String = ""
        quoteToShare = "\(savedQuote.quoteContent ?? "Content unavailable")" + " - " + "\(savedQuote.quoteAuthor ?? "Author name unavailable")"
        let activityController = UIActivityViewController(activityItems: [quoteToShare], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let windows = windowScene.windows
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.popoverPresentationController?.sourceView = windows.first
                activityController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0) // Puts activityController in the centre of screen.
                activityController.popoverPresentationController?.permittedArrowDirections = [] // Removes the directional arrow.
            }
            windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
}
