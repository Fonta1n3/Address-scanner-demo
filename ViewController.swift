//
//  ViewController.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        RPC.sharedInstance.command(method: .scantxoutset, param: "\"start\", [\"\(descriptor)\"]") { (response, errorDesc) in
            guard let response = response as? [String:Any] else {
                print("Error: \(errorDesc ?? "unknown")")
                return
            }

            completion(ScanResult(response))
        }
    }
    
    private func status(completion: @escaping (([String:Any]?)) -> Void) {
        RPC.sharedInstance.command(method: .scantxoutset, param: "\"status\"") { (response, errorDesc) in
            guard let response = response as? [String:Any] else {
                print("Error: \(errorDesc ?? "unknown")")
                return
            }

            completion(response)
        }
    }
    
    @IBAction func startScan(_ sender: Any) {
        scantxoutset(address: "tb1qq02j8e4cqfkptpr7strfkqmp4x4yujw8g8j0yg") { scanResult in
            guard let scanResult = scanResult, let amount = scanResult.total_amount else { return }
            print("address amount: \(amount)")
        }
    }
    
    @IBAction func scanStatusAction(_ sender: Any) {
        status { result in
            print("scan status: \(String(describing: result))")
        }
    }    
}

