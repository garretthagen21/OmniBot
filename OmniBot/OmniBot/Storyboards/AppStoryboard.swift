//
//  AppStoryboard.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/6/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation

enum AppStoryboard : String{
    case Main
    case BluetoothScanner
    
    var instance : UIStoryboard{
        return UIStoryboard(name: self.rawValue,bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type) -> T{
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}


