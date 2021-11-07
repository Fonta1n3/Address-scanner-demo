//
//  EncryptionKeyCreation.swift
//  demo
//
//  Created by Peter Denton on 11/7/21.
//

import Foundation

// Sets our master encryption key

class EncryptionKey {
    static func setMasterKey() -> Bool {
        guard let encryptionKey = Crypto.secret() else { return false }
        
        return KeyChain.set(encryptionKey, forKey: "encryptionKey")
    }
}
