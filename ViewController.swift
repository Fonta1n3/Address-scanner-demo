//
//  ViewController.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

import UIKit

// Our UI

class ViewController: UIViewController {
    
    @IBOutlet weak var rpcuserField: UITextField!
    @IBOutlet weak var rpcpasswordField: UITextField!
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var scanOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        rpcuserField.text = "user"
        rpcpasswordField.text = "password"
        hostField.text = "127.0.0.1"
        portField.text = "18332"
        addressField.text = "tb1qq02j8e4cqfkptpr7strfkqmp4x4yujw8g8j0yg"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        
        privKeyDemo()
    }
    
    // MARK: Demo for scanning spendable utxos for any given bitcoin address
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            
            self.rpcuserField.resignFirstResponder()
            self.rpcpasswordField.resignFirstResponder()
            self.hostField.resignFirstResponder()
            self.portField.resignFirstResponder()
            self.addressField.resignFirstResponder()
        }
    }
    
    private func help() {
        RPC.sharedInstance.command(method: .help, param: "\"scantxoutset\"") { (response, errorDesc) in
            guard let response = response else {
                print("Error: \(errorDesc ?? "unknown")")
                return
            }
            
            print("response: \(response)")
        }
    }
    
    private func scantxoutset(address: String, completion: @escaping ((ScanResult?)) -> Void) {
        let descriptor = "addr(\(address))"
        RPC.sharedInstance.command(method: .scantxoutset, param: "\"start\", [\"\(descriptor)\"]") { [weak self] (response, errorDesc) in
            guard let self = self else { return }
            
            guard let response = response as? [String:Any] else {
                self.showAlert(title: "Error", message: errorDesc ?? "unknown")
                return
            }
            
            completion(ScanResult(response))
        }
    }
    
    private func status(completion: @escaping (([String:Any]?)) -> Void) {
        RPC.sharedInstance.command(method: .scantxoutset, param: "\"status\"") { [weak self] (response, errorDesc) in
            guard let self = self else { return }
            
            guard let response = response as? [String:Any] else {
                self.showAlert(title: "Error", message: errorDesc ?? "No scan in progress.")
                return
            }

            completion(response)
        }
    }
    
    @IBAction func startScan(_ sender: Any) {
        guard let rpcuser = rpcuserField.text,
                rpcuser != "",
                let rpcpassword = rpcpasswordField.text,
                rpcpassword != "",
                let host = hostField.text,
                host != "",
                let port = portField.text,
                port != "",
                let address = addressField.text,
                address != "" else {
            
            showAlert(title: "All fields need to be filled out.", message: "Enter the node credentials along with a bitcoin address to query and tap \"start utxo scan\".")
            
            return
        }
        
        UserDefaults.standard.setValue(rpcuser, forKey: "rpcuser")
        UserDefaults.standard.setValue(rpcpassword, forKey: "rpcpassword")
        UserDefaults.standard.setValue(host, forKey: "host")
        UserDefaults.standard.setValue(port, forKey: "port")
        UserDefaults.standard.setValue(address, forKey: "address")
        
        setScanButton(enable: false)
        
        scantxoutset(address: address) { [weak self] scanResult in
            guard let self = self else { return }
            
            self.setScanButton(enable: true)
            
            guard let scanResult = scanResult,
                  let amount = scanResult.total_amount else {
                      self.showAlert(title: "Error", message: "Unknown error getting utxos for that address.")
                      return
                  }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.addressLabel.text = UserDefaults.standard.object(forKey: "address") as? String ?? ""
                self.balanceLabel.text = "Spendable balance of \(amount) btc."
                self.showAlert(title: "Scan complete ✓", message: "Spendable balance of \(amount) btc.")
            }
        }
    }
    
    @IBAction func scanStatusAction(_ sender: Any) {
        status { [weak self] result in
            guard let self = self else { return }
            
            guard let result = result,
                  let progress = result["progress"] as? Int else {
                      self.showAlert(title: "Error", message: "Unable to get scan status")
                      return
                  }
            
            self.showAlert(title: "Scan status: \(progress)% complete.", message: "")
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setScanButton(enable: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.scanOutlet.isEnabled = enable
        }
    }
    
    // MARK: Demo for private key handling
    
    private func privKeyDemo() {
        // Create master encryption key if it does not already exist:
        if KeyChain.getData("encryptionKey") == nil {
            guard EncryptionKey.setMasterKey() else {
                showAlert(title: "Fatal error...", message: "Unable to create master encryption key.")
                return
            }
        }
        
        // Take as input a private key in WIF (wallet import format)
        let wif = "L3qkvwZpSo81hB65bLYuwGf22SZhd5EEir86C5nscSHVfrjMjUvy"
        
        print("--------------------------------------------------------")
        print("Our private key in wif: \(wif)")
        print("--------------------------------------------------------")
        
        // Convert WIF private key to raw data
        guard let privateKeyData = wif.data(using: .utf8) else {
            showAlert(title: "Fatal error...", message: "Unable to convert WIF to data.")
            return
        }
        
        print("--------------------------------------------------------")
        print("Our private key in hex: \(privateKeyData.hexEncodedString())")
        print("--------------------------------------------------------")
        
        // Encrypt the private key using our master encryption key
        guard let encryptedData = Crypto.encrypt(privateKeyData) else {
            showAlert(title: "Fatal error...", message: "Unable to encrypt the private key data.")
            return
        }
        
        print("--------------------------------------------------------")
        print("Our encrypted private key in hex: \(encryptedData.hexEncodedString()))")
        print("--------------------------------------------------------")
        
        // Store the encrypted private key to CoreData
        Storage.store(encryptedData: encryptedData) { [weak self] stored in
            guard let self = self else { return }
            
            guard stored else {
                self.showAlert(title: "Fatal error...", message: "Unable to save the encrypted private key to core data.")
                return
            }
            
            print("--------------------------------------------------------")
            print("Our encrypted private key was stored successfully.")
            print("--------------------------------------------------------")
            
            // Retreive the encrypted private key(s)
            Storage.retrieve { [weak self] privateKeys in
                guard let self = self else { return }
                
                guard let privateKeys = privateKeys, !privateKeys.isEmpty else {
                    self.showAlert(title: "Fatal error...", message: "Unable to save the encrypted private key to core data.")
                    return
                }
                
                // Loop through each key and decrypt them
                for encryptedPrivateKey in privateKeys {
                    guard let decryptedPrivateKey = Crypto.decrypt(encryptedPrivateKey.privateKey) else {
                        self.showAlert(title: "Fatal error...", message: "Unable to decrypt a private key.")
                        return
                    }
                    
                    // Convert it back to WIF
                    guard let wif = String(bytes: decryptedPrivateKey, encoding: .utf8) else {
                        self.showAlert(title: "Fatal error...", message: "Unable to convert decrypted data to a string.")
                        return
                    }
                    
                    print("--------------------------------------------------------")
                    print("Our decrypted private key retrieved from storage in wif: \(wif)")
                    print("--------------------------------------------------------")
                    
                    print("--------------------------------------------------------")
                    print("Our decrypted private key retrieved from storage in hex: \(decryptedPrivateKey.hexEncodedString())")
                    print("--------------------------------------------------------")
                    
                    // Delete each private key
                    CoreDataService.deleteEntity(id: encryptedPrivateKey.id, entityName: .privateKeys) { [weak self] deleted in
                        guard let self = self else { return }
                        
                        if deleted {
                            print("--------------------------------------------------------")
                            print("Private key deleted forever.")
                            print("--------------------------------------------------------")
                        } else {
                            self.showAlert(title: "Fatal error...", message: "Unable to delete private key.")
                        }
                    }
                }
            }
        }
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

