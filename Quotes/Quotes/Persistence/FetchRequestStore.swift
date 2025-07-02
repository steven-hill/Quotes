//
//  FetchRequestStore.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import CoreData

class FetchRequestStore: NSObject, ObservableObject {
    
    enum FetchState {
        case none
        case success(data: [SavedQuote])
        case failure(error: Error)
    }
    
    private let savedQuotesController: NSFetchedResultsController<SavedQuote>
    private let context: NSManagedObjectContext
    
    @Published var savedQuotes: [SavedQuote] = []
    @Published var filteredResults = [SavedQuote]()
    @Published var fetchState: FetchState = .none
    @Published var fetchRequestHasError: Bool = false
    
    private let authorSearchRequest = "quoteAuthor CONTAINS[cd] %@"
    private let quoteSearchRequest = "quoteContent CONTAINS[cd] %@"
    
    init(savedQuotesController: NSFetchedResultsController<SavedQuote>, context: NSManagedObjectContext) {
        self.savedQuotesController = savedQuotesController
        self.context = context
        super.init()
        self.savedQuotesController.delegate = self
        tryFetch()
    }
    
    func tryFetch() {
        do {
            try savedQuotesController.performFetch()
            savedQuotes = savedQuotesController.fetchedObjects ?? []
            print("savedQuotes = \(savedQuotes)")
            fetchState = .success(data: savedQuotes)
        } catch {
            fetchRequestHasError = true
            fetchState = .failure(error: error)
        }
    }
    
    func reFetchAll() {
        savedQuotesController.fetchRequest.predicate = PersistenceController.shared.savedQuotesFetchRequest.predicate
        tryFetch()
    }
}

// MARK: - Delegate
extension FetchRequestStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updated = controller.fetchedObjects as? [SavedQuote] else { return }
        print("updated = \(updated)")
        savedQuotes = updated
    }
}

// MARK: - Delete method
extension FetchRequestStore {
    func deleteQuote(atOffsets offsets: IndexSet) {
        savedQuotes.remove(atOffsets: offsets)
    }
}

// MARK: - Search
extension FetchRequestStore {
    struct Search: Equatable {
        var query = ""
    }
    
    func filterListByAuthorOrQuote(with query: String) {
        if query.isEmpty {
            reFetchAll()
        } else {
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let authorSearchPredicate = NSPredicate(format: authorSearchRequest, trimmedQuery)
            let quoteSearchPredicate = NSPredicate(format: quoteSearchRequest, trimmedQuery)
            let compoundSearchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [authorSearchPredicate, quoteSearchPredicate])
            savedQuotesController.fetchRequest.predicate = compoundSearchPredicate
            fetchFilteredResults()
        }
    }
    
    func fetchFilteredResults() {
        do {
            try savedQuotesController.performFetch()
            filteredResults = savedQuotesController.fetchedObjects ?? []
            
            if !filteredResults.isEmpty {
                savedQuotes = filteredResults
                fetchState = .success(data: savedQuotes)
            } else {
                savedQuotes = []
                fetchState = .success(data: filteredResults)
            }
        } catch {
            fetchRequestHasError = true
            fetchState = .failure(error: error)
        }
    }
}

// MARK: - Data for SwiftUI previews
extension FetchRequestStore {
    static var preview: FetchRequestStore {
        let managedObjectContext = PersistenceController.preview.container.viewContext
        let savedQuotesController = NSFetchedResultsController(fetchRequest: PersistenceController.shared.savedQuotesFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        let previewStore = FetchRequestStore(savedQuotesController: savedQuotesController, context: managedObjectContext)
        return previewStore
    }
}

extension FetchRequestStore.FetchState: Equatable {
    static func == (lhs: FetchRequestStore.FetchState, rhs: FetchRequestStore.FetchState) -> Bool {
        switch (lhs, rhs) {
        case(.none, .none):
            return true
        case(.success(let lhsType), .success(let rhsType)):
            return lhsType == rhsType
        case(.failure(let lhsType), .failure(let rhsType)):
            return lhsType.localizedDescription == rhsType.localizedDescription
        default:
            return false
        }
    }
}
