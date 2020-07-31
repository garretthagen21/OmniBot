//
//  UserSettings.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/6/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation

enum BluetoothMode:String{
      case instantUpdate = "Instant Update"
      case delayedUpdate = "Delayed Update"
      case continuousUpdate = "Continuous Update"
  }

class UserSettings {
  
    static var defaultBluetoothPeripheral:String
    {
        get{ return UserDefaults.standard.string(forKey: "defaultBluetoothPeripheral") ?? "" }
        set(peripheralName) { UserDefaults.standard.set(peripheralName,forKey: "defaultBluetoothPeripheral" )}
    }
    
    static var bluetoothMode:BluetoothMode{
        get{ return BluetoothMode(rawValue: UserDefaults.standard.string(forKey: "bluetoothMode")!) ?? .instantUpdate }
        set(newMode) {
            UserDefaults.standard.set(newMode.rawValue,forKey: "bluetoothMode")
            NotificationCenter.default.post(name: .bluetoothModeChanged,object: (UserSettings.bluetoothMode,UserSettings.bluetoothTime))
        }
           
        
        
    }
    
    static var bluetoothTime:Double{
        get{ return UserDefaults.standard.double(forKey: "bluetoothTime") }
        set(newTime) {
            UserDefaults.standard.set(newTime,forKey: "bluetoothTime")
            NotificationCenter.default.post(name: .bluetoothModeChanged,object: (UserSettings.bluetoothMode,UserSettings.bluetoothTime))
            
        }
    }
    
    static var autoConnect:Bool{
         get{ return UserDefaults.standard.bool(forKey: "autoConnect") }
           set(newAuto) { UserDefaults.standard.set(newAuto,forKey: "autoConnect")

        }
    }
    
    static var confirmGesture:Bool{
         get{ return UserDefaults.standard.bool(forKey: "confirmGesture") }
           set(newGesture) { UserDefaults.standard.set(newGesture,forKey: "confirmGesture")

        }
    }
    
    
    static func resetToDefaults()
    {
        defaultBluetoothPeripheral = "OmniBot"
        bluetoothMode = .continuousUpdate
        bluetoothTime = 0.5
        autoConnect = true
        confirmGesture = true
    }
    

    
}
