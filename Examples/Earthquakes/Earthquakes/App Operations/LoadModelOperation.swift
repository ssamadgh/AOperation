/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This file contains the code to create the Core Data stack.
 */

import CoreData
import AOperation

/**
 An `Operation` subclass that loads the Core Data stack. If this operation fails,
 it will produce an `AlertOperation` that will offer to retry the operation.
 */
class LoadModelOperation: AOperation {
    // MARK: Properties
    
    let loadHandler: (NSManagedObjectContext) -> Void
    
    // MARK: Initialization
    
    init(loadHandler: @escaping (NSManagedObjectContext) -> Void) {
        self.loadHandler = loadHandler
        
        super.init()
        
        // We only want one of these going at a time.
        addCondition(MutuallyExclusive<LoadModelOperation>())
    }
    
    override func execute() {
        /*
         We're not going to handle catching the error here, because if we can't
         get the Caches directory, then your entire sandbox is broken and
         there's nothing we can possibly do to fix it.
         */
        let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let storeURL = cachesFolder.appendingPathComponent("earthquakes.sqlite")
        
        /*
         Force unwrap this model, because this would only fail if we haven't
         included the xcdatamodel in our app resources. If we forgot that step,
         we deserve to crash. Plus, there's really no easy way to recover from
         a missing model without reconstructing it programmatically
         */
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        var error = createStore(persistentStoreCoordinator, atURL: storeURL)
        
        if persistentStoreCoordinator.persistentStores.isEmpty {
            /*
             Our persistent store does not contain irreplaceable data (which
             is why it's in the Caches folder). If we fail to add it, we can
             delete it and try again.
             */
            destroyStore(persistentStoreCoordinator, atURL: storeURL)
            error = createStore(persistentStoreCoordinator, atURL: storeURL)
        }
        
        if persistentStoreCoordinator.persistentStores.isEmpty {
            print("Error creating SQLite store: \(String(describing: error)).")
            print("Falling back to `.InMemory` store.")
            error = createStore(persistentStoreCoordinator, atURL: nil, type: NSInMemoryStoreType)
        }
        
        if !persistentStoreCoordinator.persistentStores.isEmpty {
            loadHandler(context)
            error = nil
        }
        
        finishWithError(error)
    }
    
    fileprivate func createStore(_ persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: Foundation.URL?, type: String = NSSQLiteStoreType) -> AOperationError? {
        var error: AOperationError?
        do {
            let _ = try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: URL, options: nil)
        }
        catch let storeError as NSError {
			error = storeError.mapToAOperatonError(state: .executionFailed, key: self.name!)
        }
        
        return error
    }
    
    fileprivate func destroyStore(_ persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: Foundation.URL, type: String = NSSQLiteStoreType) {
        do {
            let _ = try persistentStoreCoordinator.destroyPersistentStore(at: URL, ofType: type, options: nil)
        }
        catch { }
    }
    
    override func finished(_ errors: [AOperationError]) {
        guard let firstError = errors.first, userInitiated else { return }
        
        /*
         We failed to load the model on a user initiated operation try and present
         an error.
         */
        
        let alert = AlertOperation()
        
        alert.title = "Unable to load database"
        
        alert.message = "An error occurred while loading the database. \(firstError.localizedDescription ?? ""). Please try again later."
        
        // No custom action for this button.
        alert.addAction("Retry Later", style: .cancel)
        
        // Declare this as a local variable to avoid capturing self in the closure below.
        let handler = loadHandler
        
        /*
         For this operation, the `loadHandler` is only ever invoked if there are
         no errors, so if we get to this point we know that it was not executed.
         This means that we can offer to the user to try loading the model again,
         simply by creating a new copy of the operation and giving it the same
         loadHandler.
         */
        alert.addAction("Retry Now") { alertOperation in
            let retryOperation = LoadModelOperation(loadHandler: handler)
            
            retryOperation.userInitiated = true
            
            alertOperation.produceOperation(retryOperation)
        }
        
        produceOperation(alert)
    }
}

