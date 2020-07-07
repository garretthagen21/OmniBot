//
//  UserSettings.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/6/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation


class UserSettings {
    
    static var defaultBluetoothPeripheral:String
    {
        get{ return UserDefaults.standard.string(forKey: "defaultBluetoothPeripheral") ?? "" }
        set(peripheralName) { UserDefaults.standard.set(peripheralName,forKey: "defaultBluetoothPeripheral" )}
    }
    
    
    static func resetToDefaults()
    {
        defaultBluetoothPeripheral = "OmniBot"
    }
    

    
}
