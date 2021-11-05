//
//  ScanResult.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

import Foundation
 /*
 {
     bestblock = 000000000000000cdd92ddfa34424d1fb88456241113577cd0d59a4d680e3a58;
     height = 2102696;
     success = 1;
     "total_amount" = "0.0001";
     txouts = 26307564;
     unspents =         (
                     {
             amount = "0.0001";
             desc = "addr(tb1qq02j8e4cqfkptpr7strfkqmp4x4yujw8g8j0yg)#76k35q66";
             height = 2101946;
             scriptPubKey = 001403d523e6b8026c15847e82c69b0361a9aa4e49c7;
             txid = 17ed9fd31675f6c7e07949f65e85e6d4cb6cd8a593c2cf0b26277a110a101349;
             vout = 1;
         }
     );
 }
 
 */

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
