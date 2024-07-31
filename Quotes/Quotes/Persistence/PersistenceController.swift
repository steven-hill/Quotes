//
//  PersistenceController.swift
//  Quotes
//
//  Created by Steven Hill on 25/07/2024.
//

import Foundation
import CoreData

class PersistenceController: ObservableObject {
    
    enum PersistenceError: Error, LocalizedError {
        case none
        case loadingError(error: Error)
        case saveError(error: Error)
    }
    
    @Published var hasError: Bool = false
    @Published private(set) var persistenceError: PersistenceError = .none
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<15 {
            let previewQuote = SavedQuote(context: viewContext)
            previewQuote.quoteContent = "This is a persisted quote for the preview."
            previewQuote.quoteAuthor = "Author's name goes here."
            previewQuote.reflection = "Interesting quote."
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Quotes")
        container.viewContext.automaticallyMergesChangesFromParent = true
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
                self.hasError = true
                self.persistenceError = .loadingError(error: error)
            }
        })
    }
}

extension PersistenceController {
    var savedQuotesFetchRequest: NSFetchRequest<SavedQuote> {
        let request: NSFetchRequest<SavedQuote> = SavedQuote.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedQuote.quoteAuthor, ascending: true)]
        return request
    }
    
    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
                self.hasError = true
                self.persistenceError = .saveError(error: error)
                throw PersistenceError.saveError(error: error)
            }
        }
    }
    
    func delete(savedQuote: SavedQuote) throws {
        let context = container.viewContext
        let quoteToBeDeleted = try context.existingObject(with: savedQuote.objectID)
        context.delete(quoteToBeDeleted)
        Task(priority: .background) {
            try await context.perform {
                try context.save()
            }
        }
    }
}

extension PersistenceController.PersistenceError: Equatable {
    static func == (lhs: PersistenceController.PersistenceError, rhs: PersistenceController.PersistenceError) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loadingError(let lhsError), .loadingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.saveError(let lhsError), .saveError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
