//
//  StoreEncryptedKey.swift
//  demo
//
//  Created by Peter Denton on 11/7/21.
//

import Foundation

// Boiler plate code for storing a single encrypted private key and retreiving all encrypted private keys.

class Storage {
    
    static func store(encryptedData: Data, completion: @escaping (Bool) -> Void) {
        let entity:[String:Any] = [
            "id": UUID(),
            "privateKey": encryptedData
        ]
        
        CoreDataService.saveEntity(dict: entity, entityName: .privateKeys) { saved in
            completion(saved)
        }
    }
    
    static func retrieve(completion: @escaping ([PrivateKey]?) -> Void) {
        CoreDataService.retrieveEntity(entityName: .privateKeys) { privateKeys in
            guard let privateKeys = privateKeys, privateKeys.count > 0 else {
                completion(nil)
                return
            }
            
            var privateKeyArray:[PrivateKey] = []
            
            for (i, privateKey) in privateKeys.enumerated() {
                let privKeyObject = PrivateKey(privateKey)
                privateKeyArray.append(privKeyObject)
                
                if i + 1 == privateKeys.count {
                    completion(privateKeyArray)
                }
            }
        }
    }
}
