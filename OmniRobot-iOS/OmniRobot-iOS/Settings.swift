//
//  Settings.swift
//  BiometricDoor-iOS
//
//  Created by Garrett Hagen on 1/9/19.
//  Copyright © 2019 Garrett Hagen. All rights reserved.
//

import Foundation
import UIKit

class Settings {
    
    static var hideBlurItems:Bool
    {
        get{ return UserDefaults.standard.bool(forKey: "hideBlurItems") }
        set(onOff) { UserDefaults.standard.set(onOff,forKey: "hideBlurItems" )}
    }
    
    static var hideBlurBackground:Bool
    {
        get{ return UserDefaults.standard.bool(forKey: "hideBlurBackground") }
        set(onOff) { UserDefaults.standard.set(onOff,forKey: "hideBlurBackground" )}
    }
    
    static var darkMode:Bool
    {
        get{ return UserDefaults.standard.bool(forKey: "darkMode") }
        set(onOff) { UserDefaults.standard.set(onOff,forKey: "darkMode" )}
    }
   
    static var masterPassword:[Int]
    {
        get{ return UserDefaults.standard.array(forKey: "masterPassword") as! [Int] }
        set(newArray){ UserDefaults.standard.set(newArray, forKey: "masterPassword") }
    }
  
    static var timerOn:Bool
    {
        get{ return UserDefaults.standard.bool(forKey: "timerOn") }
        set(onOff) { UserDefaults.standard.set(onOff,forKey: "timerOn" )}
    }
    
    static var timerMinutes:Double
    {
        get{ return UserDefaults.standard.double(forKey: "timerMinutes") }
        set(newTime) { UserDefaults.standard.set(newTime,forKey: "timerMinutes" )}
    }
    
    static var isLocked:Bool
    {
        get{ return UserDefaults.standard.bool(forKey: "isLocked") }
        set(onOff) { UserDefaults.standard.set(onOff,forKey: "isLocked" )}
    }
    
    static var fingerPrintIDs:[String:String]
    {
        get{ return UserDefaults.standard.dictionary(forKey: "fingerPrintIDs") as! [String:String] }
        set(newIDs) { UserDefaults.standard.set(newIDs,forKey: "fingerPrintIDs" )}
    }
    
    static var backgroundImage:UIImage = UIImage(named: "galaxy-iphone-wallpaper-20")! // Note: This will reset when the app terminates
    static let cornerRadius:Float = 12.5

  

    static func resetToDefaults()
    {
        hideBlurItems = true
        hideBlurBackground = true
        darkMode = false
        masterPassword = [1,2,3,4,5,6]
        backgroundImage = UIImage(named: "galaxy-iphone-wallpaper-20")!
        timerOn = false
        timerMinutes = 3
        isLocked = true
        fingerPrintIDs = [:]

    }
    

    
}
