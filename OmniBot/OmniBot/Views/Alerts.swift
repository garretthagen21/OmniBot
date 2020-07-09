//
//  Alerts.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/8/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//


import Foundation
import UIKit


struct Alerts
{
    private var progressHUD: MBProgressHUD?
    
    static func dismissableAlert(title: String,message: String,option: String,view: UIViewController =  UIApplication.shared.currentViewController()!){
        
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: option, style: UIAlertAction.Style.default, handler: { action -> Void in alert.dismiss(animated: true, completion: nil) }))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func createHUD(textValue: String, delayLength: Double, view: UIView =  UIApplication.shared.currentViewController()!.view){
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = textValue
        hud?.hide(true, afterDelay: delayLength)
    }
    
    static func createProgressHUD(textValue: String, view: UIView = UIApplication.shared.currentViewController()!.view) -> MBProgressHUD
    {
        
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD!.labelText = textValue
        return progressHUD!
    }

}




