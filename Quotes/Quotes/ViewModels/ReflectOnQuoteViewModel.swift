//
//  ReflectOnQuoteViewModel.swift
//  Quotes
//
//  Created by Steven Hill on 18/09/2026.
//

import Foundation

@Observable
final class ReflectOnQuoteViewModel {
    
    //MARK: - Properties
    private(set) var isQuoteSaved: Bool = false
    var hasError: Bool = false
    var errorMessage: String = ""
    var showConfirmationDialog: Bool = false
}
