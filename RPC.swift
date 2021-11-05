//
//  RPC.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

import Foundation

class RPC {
    
    static let sharedInstance = RPC()
    
    private init() {}
        
    func command(method: BTC_CLI_COMMAND, param: Any, completion: @escaping ((response: Any?, errorDesc: String?)) -> Void) {
        let rpcuser = UserDefaults.standard.object(forKey: "rpcuser") as? String ?? "user"
        let rpcpassword = UserDefaults.standard.object(forKey: "rpcpassword") as? String ?? "password"
        let host = UserDefaults.standard.object(forKey: "host") as? String ?? "127.0.0.1"
        let port = UserDefaults.standard.object(forKey: "port") as? String ?? "18332"
        
        guard let url = URL(string: "http://\(rpcuser):\(rpcpassword)@\(host):\(port)") else {
            fatalError("Unable to convert node credentials to a valid URL.")
        }
        
        let loginString = String(format: "%@:%@", rpcuser, rpcpassword)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let id = UUID()
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 600
        request.httpMethod = "POST"
        request.addValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"jsonrpc\":\"1.0\",\"id\":\"\(id)\",\"method\":\"\(method.rawValue)\",\"params\":[\(param)]}".data(using: .utf8)
        
        #if DEBUG
        print("url = \(url)")
        print("request: \("{\"jsonrpc\":\"1.0\",\"id\":\"\(id)\",\"method\":\"\(method.rawValue)\",\"params\":[\(param)]}")")
        #endif
        
        let session = URLSession(configuration: .default)
                
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let urlContent = data else {
                
                guard let error = error else {
                    completion((nil, "Unknown error, ran out of attempts"))
                    return
                }
                
                #if DEBUG
                print("error: \(error.localizedDescription)")
                #endif
                
                completion((nil, error.localizedDescription))
                
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: urlContent, options: .mutableLeaves) as? NSDictionary else {
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 401:
                        completion((nil, "Looks like your rpc credentials are incorrect, please double check them. If you changed your rpc creds in your bitcoin.conf you need to restart your node for the changes to take effect."))
                    case 403:
                        completion((nil, "The bitcoin-cli \(method) command has not been added to your rpcwhitelist, add \(method) to your bitcoin.conf rpcwhitelsist, reboot Bitcoin Core and try again."))
                    default:
                        completion((nil, "Unable to decode the response from your node, http status code: \(httpResponse.statusCode)"))
                    }
                } else {
                    completion((nil, "Unable to decode the response from your node..."))
                }
                return
            }
            
            #if DEBUG
            print("json: \(json)")
            #endif
            
            guard let errorCheck = json["error"] as? NSDictionary else {
                completion((json["result"], nil))
                return
            }
            
            guard let errorMessage = errorCheck["message"] as? String else {
                completion((nil, "Uknown error from bitcoind"))
                return
            }
            
            completion((nil, errorMessage))
        }
        
        task.resume()
    }
}



