//
//  Commands.swift
//  demo
//
//  Created by Peter Denton on 11/5/21.
//

// List of bitcoin-cli commands we can call with RPC.swift

import Foundation

public enum BTC_CLI_COMMAND: String {
    case scantxoutset = "scantxoutset"
    case help = "help"
}
