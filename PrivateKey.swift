//
//  PrivateKey.swift
//  demo
//
//  Created by Peter Denton on 11/7/21.
//

import Foundation

// A struct to define our PrivateKey object, it only exists for conveneince/readability as it is much cleaner handling structs then raw ditcionaries.

public struct PrivateKey: CustomStringConvertible {
    let id:UUID
    let privateKey:Data
    
    init(_ dictionary: [String: Any]) {
        id = dictionary["id"] as! UUID
        privateKey = dictionary["privateKey"] as! Data
    }
    
    public var description: String {
        return "An encrypted private key object from Core Data."
    }
    
}
