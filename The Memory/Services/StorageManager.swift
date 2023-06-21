//
//  StorageManager.swift
//  The Memory
//
//  Created by Andrei on 21/6/23.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
   
    
    
    // MARK: - Core Data stack

    private let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "The_Memory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    func saveTime(_ timeString: String, completion: (GameTime) -> Void ) {
        let gameTime = GameTime(context: viewContext)
        gameTime.time = timeString
        completion(gameTime)
        saveContext()
    }
    
    func fetchData(completion: (Result<[GameTime], Error>) -> Void ) {
        let fetchRequest = GameTime.fetchRequest()
        
        do {
            let timeList = try viewContext.fetch(fetchRequest)
            completion(.success(timeList))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func cleanData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GameTime.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? viewContext.execute(batchDeleteRequest)
    }
    
    func cleanData2() {
        let fetchRequest = GameTime.fetchRequest()
        let items = try? viewContext.fetch(fetchRequest)
        for item in items ?? [] {
            viewContext.delete(item)
        }
        
        try? viewContext.save()
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


