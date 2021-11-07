//
//  CoreDataService.swift
//  demo
//
//  Created by Peter Denton on 11/7/21.
//

import Foundation
import CoreData
import UIKit

// Boiler plate code for interacting with Core Data entities.

class CoreDataService {
    
    enum ENTITY: String {
        case privateKeys = "PrivateKeys"
    }
    
    class func saveEntity(dict: [String:Any], entityName: ENTITY, completion: @escaping ((Bool)) -> Void) {
        DispatchQueue.main.async {

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                completion(false)
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext

            guard let entity = NSEntityDescription.entity(forEntityName: entityName.rawValue, in: context) else {
                completion(false)
                return
            }

            let credential = NSManagedObject(entity: entity, insertInto: context)
            var success = false

            for (key, value) in dict {
                credential.setValue(value, forKey: key)
                do {
                    try context.save()
                    success = true
                } catch {
                }
            }
            completion(success)
        }
    }
    
    class func retrieveEntity(entityName: ENTITY, completion: @escaping (([[String:Any]]?)) -> Void) {
        DispatchQueue.main.async {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                completion(nil)
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName.rawValue)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.resultType = .dictionaryResultType
            
            do {
                if let results = try context.fetch(fetchRequest) as? [[String:Any]] {
                    completion(results)
                }
            } catch {
                completion(nil)
            }
        }
    }
    
    class func deleteEntity(id: UUID, entityName: ENTITY, completion: @escaping ((Bool)) -> Void) {
        DispatchQueue.main.async {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                completion(false)
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName.rawValue)
            fetchRequest.returnsObjectsAsFaults = false
            
            guard let results = try? context.fetch(fetchRequest) as [NSManagedObject], results.count > 0 else {
                completion(false)
                return
            }
            
            for (index, data) in results.enumerated() {
                if id == data.value(forKey: "id") as? UUID {
                    context.delete(results[index] as NSManagedObject)
                    do {
                        try context.save()
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            }
        }
    }
    
}

