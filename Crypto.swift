//
//  Crypto.swift
//  demo
//
//  Created by Peter Denton on 11/7/21.
//

import Foundation
import CryptoKit

// Boiler plate code for encryption

class Crypto {
    static func secret() -> Data? {
        var bytes = [UInt8](repeating: 0, count: 32)
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard result == errSecSuccess else {
            print("Problem generating random bytes")
            return nil
        }

        return Crypto.sha256hash(Crypto.sha256hash(Crypto.sha256hash(Data(bytes))))
    }
    
    static func sha256hash(_ data: Data) -> Data {
        let digest = SHA256.hash(data: data)
        
        return Data(digest)
    }
    
    static func encrypt(_ data: Data) -> Data? {
        guard let key = KeyChain.getData("encryptionKey") else { return nil }
        
        return try? ChaChaPoly.seal(data, using: SymmetricKey(data: key)).combined
    }
    
    static func decrypt(_ data: Data) -> Data? {
        guard let key = KeyChain.getData("encryptionKey"),
            let box = try? ChaChaPoly.SealedBox.init(combined: data) else {
                return nil
        }
        
        return try? ChaChaPoly.open(box, using: SymmetricKey(data: key))
    }
    
}
