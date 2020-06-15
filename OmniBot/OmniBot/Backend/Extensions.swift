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


