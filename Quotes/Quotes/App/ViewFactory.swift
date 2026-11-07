//
//  ViewFactory.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import SwiftUI

/// Manages `SwiftUI` presentation dependencies.
final class ViewFactory {
    
    //MARK: - Dependencies
    private let dependencies: AppDependencyContaining
    private let coordinator: AppCoordinating
    
    //MARK: - Initialisation
    init(
        dependencies: AppDependencyContaining,
        coordinator: AppCoordinating
    ) {
        self.dependencies = dependencies
        self.coordinator = coordinator
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
    
    func makeSavedCardView(
        savedQuote: Quote,
        savedVM: SavedViewModel
    ) -> SavedCardView {
        SavedCardView(
            savedQuote: savedQuote,
            factory: self,
            savedVM: savedVM
        )
    }
    
    func makeEditReflectionView(
        savedQuote: Quote,
        userThoughts: String,
        successfulSave: @escaping () -> Void,
        refreshList: @escaping () -> Void
    ) -> EditReflectionView {
        EditReflectionView(
            savedQuote: savedQuote,
            quoteRepository: dependencies.quoteRepository,
            userThoughts: userThoughts,
            successfulSave: successfulSave,
            refreshList: refreshList
        )
    }
    
    func makeSettingsView() -> SettingsView {
        SettingsView(
            appearanceManager: dependencies.appearanceManager,
            localNotificationsManager: dependencies.localNotificationsManager,
            factory: self
        )
    }
    
    func makeNotificationDeniedSectionView() -> NotificationDeniedSection {
        NotificationDeniedSection(coordinator: coordinator)
    }
}
