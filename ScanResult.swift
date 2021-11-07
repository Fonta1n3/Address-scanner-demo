//
//  ScanResult.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

import Foundation

// An object to make handling the scan result cleaner.

public struct ScanResult: CustomStringConvertible {
    
    let height:Int?
    let total_amount:Double?
    let success:Bool?
    let unspents:[[String:Any]]?
    let bestblock:String?
    let txouts:Int?
    
    init(_ dict: [String: Any]) {
        height = dict["height"] as? Int
        total_amount = dict["total_amount"] as? Double
        success = dict["success"] as? Bool
        unspents = dict["unspents"] as? [[String:Any]]
        bestblock = dict["bestblock"] as? String
        txouts = dict["txouts"] as? Int
    }
    
    public var description: String {
        return ""
    }
}
