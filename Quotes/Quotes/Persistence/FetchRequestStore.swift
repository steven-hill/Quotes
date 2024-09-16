//
//  FetchRequestStore.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import CoreData

protocol FetchRequestStoreProtocol {
    func tryFetch()
}

class FetchRequestStore: NSObject, ObservableObject, FetchRequestStoreProtocol {
    
    enum FetchState {
        case none
        case success(data: [SavedQuote])
        case failure(error: Error)
    }
    
    let context = PersistenceController.shared.container.viewContext
    
    @Published var savedQuotes: [SavedQuote] = []
    @Published var filteredResults = [SavedQuote]()
    @Published var fetchState: FetchState = .none
    @Published var fetchRequestError: Bool = false
    let savedQuotesController: NSFetchedResultsController<SavedQuote>
    
    let request = "quoteAuthor CONTAINS[cd] %@"
    
    init(managedObjectContext: NSManagedObjectContext) {
        savedQuotesController = NSFetchedResultsController(fetchRequest: PersistenceController.shared.savedQuotesFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        savedQuotesController.delegate = self
        tryFetch()
    }
    
    func tryFetch() {
        do {
            try savedQuotesController.performFetch()
            savedQuotes = savedQuotesController.fetchedObjects ?? []
            print("savedQuotes = \(savedQuotes)")
            fetchState = .success(data: savedQuotes)
        } catch {
            fetchRequestError = true
            fetchState = .failure(error: error)
        }
    }
    
    func reFetchAll() {
        savedQuotesController.fetchRequest.predicate = PersistenceController.shared.savedQuotesFetchRequest.predicate
        tryFetch()
    }
}

extension FetchRequestStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updated = controller.fetchedObjects as? [SavedQuote] else { return }
        print("updated = \(updated)")
        savedQuotes = updated
    }
    
    func deleteQuote(atOffsets offsets: IndexSet) {
        savedQuotes.remove(atOffsets: offsets)
    }
}

extension FetchRequestStore {
    struct Search: Equatable {
        var query = ""
    }
    
    func filterListByAuthor(with query: String) {
        if query.isEmpty {
            reFetchAll()
        } else {
            let searchPredicate = NSPredicate(format: request, query)
            savedQuotesController.fetchRequest.predicate = searchPredicate
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
            fetchRequestError = true
            fetchState = .failure(error: error)
        }
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
