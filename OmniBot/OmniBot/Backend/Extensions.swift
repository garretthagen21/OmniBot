//
//  Extensions.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/15/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation
import UIKit


extension Bundle {

    /**
     Locate an inner Bundle generated from CocoaPod packaging.

     - parameter name: the name of the inner resource bundle. This should match the "s.resource_bundle" key or
       one of the "s.resoruce_bundles" keys from the podspec file that defines the CocoPod.
     - returns: the resource Bundle or `self` if resource bundle was not found
    */
    func podResource(name: String) -> Bundle {
        guard let bundleUrl = self.url(forResource: name, withExtension: "bundle") else { return self }
        return Bundle(url: bundleUrl) ?? self
    }
}

extension Notification.Name {
    static var commanderChanged: Notification.Name {
        return .init(rawValue: "RobotCommander.commanderChanged")
    }
    
    
    static var bluetoothStatusChanged : Notification.Name{
        return .init(rawValue: "BluetoothSerial.bluetoothStatusChanged")
    }
    static var bluetoothModeChanged : Notification.Name
    {
        return .init(rawValue: "UserSettings.bluetoothModeChanged")
    }
 
}

extension UIView {

    func rotate(degrees: CGFloat) {


        let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
            return degrees / 180.0 * CGFloat.pi
        }
        self.transform =  CGAffineTransform(rotationAngle: degreesToRadians(degrees))

    }

}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
    
    
    func rotate(degrees: CGFloat) -> UIImage{
        return self.rotate(radians: (.pi * degrees) / 180.0)
    }
}

extension UIViewController{
    class var storyboardID: String{
        return "\(self)"
    }
    static func instantiateFromAppStoryboard(appStoryboard : AppStoryboard) -> Self{
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
   
        /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
        func setupHideKeyboardOnTap() {
            self.view.addGestureRecognizer(self.endEditingRecognizer())
            self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
        }

        /// Dismisses the keyboard from self.view
        private func endEditingRecognizer() -> UIGestureRecognizer {
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
            tap.cancelsTouchesInView = false
            return tap
    }
    
}


extension UIApplication {
    func currentViewController() -> UIViewController? {
        let newKeyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return newKeyWindow?.rootViewController?.topMostViewController()
    }
}

enum Segues:String{
    case BluetoothScannerSegue
    case EmbeddedDashboardSegue
}


extension UIColor{
    static var systemLabel:UIColor{ UIColor{
        traitCollection in
        switch traitCollection.userInterfaceStyle {
           case .dark:
               return UIColor.white
           default:
               return UIColor.black
            }
        }
    }
    
    static var systemSecondaryLabel:UIColor{ UIColor{
        traitCollection in
        switch traitCollection.userInterfaceStyle {
           case .dark:
               return UIColor.white
           default:
               return UIColor.black
            }
        }
    }
}



