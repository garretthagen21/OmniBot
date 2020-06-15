//
//  Dashboard.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/8/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation
import UIKit


class DashboardView : UIView
{
    let kCONTENT_XIB_NAME = "DashboardView"

    @IBOutlet weak var bluetoothImageView: UIImageView!
    @IBOutlet weak var bluetoothLabel: UILabel!
    @IBOutlet weak var autopilotStatusLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var steeringImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
    }
        

}

/// Implementation of dashboard functionality
extension DashboardView{
    
    
    
}
