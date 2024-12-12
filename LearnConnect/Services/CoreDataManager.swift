import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LearnConnect")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Core Data Operations
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let error = error as NSError
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - CRUD Operations
    func fetch<T: NSManagedObject>(_ type: T.Type,
                                  predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let request = T.fetchRequest() as! NSFetchRequest<T>
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
    
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []
            ]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
        } catch {
            print("Failed to delete all: \(error)")
        }
    }
}
