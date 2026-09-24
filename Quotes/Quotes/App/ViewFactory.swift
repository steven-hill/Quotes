//
//  ViewFactory.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import SwiftUI

/// Manages `SwiftUI` presentation dependencies.
final class ViewFactory {
    
    //MARK: - Dependency
    private let dependencies: AppDependencyContaining
    
    //MARK: - Initialisation
    init(dependencies: AppDependencyContaining) {
        self.dependencies = dependencies
    }
    
    //MARK: - View Creation Methods
    func makeQuoteOfTheDayView() -> QuoteOfTheDayView {
        QuoteOfTheDayView(
            networkClient: dependencies.networkClient,
            factory: self
        )
    }
    
    func makeReflectOnQuoteView(
        quoteContent: String,
        quoteAuthor: String,
        successfulSave: @escaping () -> Void
    ) -> ReflectOnQuoteView {
        return ReflectOnQuoteView(
            quoteContent: quoteContent,
            quoteAuthor: quoteAuthor,
            quoteRepository: dependencies.quoteRepository,
            successfulSave: successfulSave
        )
    }
    
    func makeSavedView() -> SavedView {
        SavedView(
            quoteRepository: dependencies.quoteRepository,
            factory: self
        )
    }
    
    func makeSavedCardView(savedQuote: Quote) -> SavedCardView {
        SavedCardView(
            savedQuote: savedQuote,
            factory: self
        )
    }
    
    func makeEditReflectionView(
        savedQuote: Quote,
        userThoughts: String,
        successfulSave: @escaping () -> Void
    ) -> EditReflectionView {
        EditReflectionView(
            savedQuote: savedQuote,
            userThoughts: userThoughts,
            successfulSave: successfulSave
        )
    }
}
