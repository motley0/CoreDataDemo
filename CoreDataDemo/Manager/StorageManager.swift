//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Dmitry Shcherbakov on 24.11.2020.
//
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: {
            if let error = $1 {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    private init() {}
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    func createTask(taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription.entity(
                forEntityName: "Task",
                in: persistentContainer.viewContext
        ) else { return nil }
        guard let task = NSManagedObject(
                entity: entityDescription,
                insertInto: persistentContainer.viewContext
        ) as? Task else { return nil }
        
        task.name = taskName
        saveContext()
        
        return task
    }
    
    func fetchTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
            return []
        }
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
        saveContext()
    }
    
}
