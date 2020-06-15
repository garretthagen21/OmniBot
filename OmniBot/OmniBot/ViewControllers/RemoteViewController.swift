//
//  FirstViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import UIKit
import BRHJoyStickView

class RemoteViewController: UIViewController {

    @IBOutlet weak var joystickView: JoyStickView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup joystick to update our robot command on changes
        let bundle = Bundle(for: JoyStickView.self).podResource(name: "BRHJoyStickView")
        let joystickMonitor: JoyStickViewXYMonitor = { joystickReport in
            if joystickReport.x > 0.0 || joystickReport.y > 0.0 {
               print("Joystick XY: (\(joystickReport.x),\(joystickReport.y))")
                
               // TODO: Need to scale joystick values to be in range -1.0 to 1.0
                
               // TODO: If they touch the joystick with auto pilot on, notify somehow that we
               // are turning off auto pilot or give them the option too
               RobotCommander.velocityValue = Double(joystickReport.y)
               RobotCommander.turnValue = Double(joystickReport.x)
           }
        }
        joystickView.baseImage = UIImage(named: "FancyBase", in: bundle, compatibleWith: nil)
        joystickView.handleImage = UIImage(named: "FancyHandle", in: bundle, compatibleWith: nil)
        joystickView.monitor = .xy(monitor: joystickMonitor)
    }


}

