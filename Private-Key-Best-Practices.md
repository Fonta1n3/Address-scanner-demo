#  Private Key Best Practices

1. Generate a master encryption key that will be used to encrypt/decrypt sensitive data:
    - [Crypto.swift](./Crypto.swift) for the boiler plate code.

```
    static func secret() -> Data? {
        // Set the number of bytes for our secret data
        var bytes = [UInt8](repeating: 0, count: 32)
        
        // Create the entropy using Apple's Sec class
        let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        // Ensure no errors were encountered
        guard result == errSecSuccess else {
            print("Problem generating random bytes")
            return nil
        }
        
        // Return a triple sha256 hash of the secret bytes
        return Crypto.sha256hash(Crypto.sha256hash(Crypto.sha256hash(Data(bytes))))
    }
```


2. Store this encryption key on the devices secure enclave (aka Keychain), the secure enclave is itself encrypted
    - [Keychain data protection](https://support.apple.com/guide/security/keychain-data-protection-secb0694df1a/web)
    - [Storing encryption keys on the keychain](https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain)
    - [Keychain.swift](./Keychain.swift) for the boiler plate code.

```
    static func setMasterKey() -> Bool {
        // Create the encryption key by calling the secret() funtion from our Crypto class
        guard let encryptionKey = Crypto.secret() else { return false }
        
        // Return a boolean based on the success of storing our encryption key on the keychain
        return KeyChain.set(encryptionKey, forKey: "encryptionKey")
    }
```
    
3. Using Apple's native cryptography library `CryptoKit` we encrypt any sensitive data (such as private keys or seeds) with our master encryption key,
only ever storing them to memory in their encrypted state.

```
    static func encryptPrivateKey() -> Data? {
        // Create a dummy private key
        let bitcoinPrivateKey = "L3vRPgxyjBwJVbwtAs8NL8iQWHsVYDKjSwaKnZ9BuNGSZ5ShM2ME"
        
        // Convert the string representaion to data
        guard let privKeyData = bitcoinPrivateKey.data(using: .utf8) else { return nil }
        
        // Return the encrypted private key data
        return Crypto.encrypt(privKeyData)
    }
```

4. For storage we use Apple's `CoreData`, optionally enabling the `Data Protection` capability which adds an additional layer of encryption to all CoreData items.
    - In the Xcode project ensure you enable CoreData when creating the project and create your Entities
    - We create an Entity called `PrivateKeys`, this is essentially an array of encrypted private keys.
    - Our `PrivateKeys` entity contains attributes of `privateKey` stored as binary data (our encrypted key) and an `id` stored as UUID so we can fetch/delete specific items via their unique id's.
    - [CoreData Entity](./demo.xcdatamodeld)
    - [CoreDataService.swift](./CoreDataService.swift) is our boiler plate code for interacting with Core Data.
    - [Storage.swift](./Storage.swift) contains two functions for saving and retreiving our encrypted private keys.
    
5. To see it all in action refer to [privKeyDemo()](./ViewController.swift) on line #170. This function:
    - sets our master encryption key
    - takes as input a private key in WIF format
    - encryts the private key
    - saves it to Core Data
    - decrypts the private key
    - deletes the private key from Core Data







