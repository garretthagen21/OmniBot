//
//  FirstViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import UIKit
import BRHJoyStickView
import CocoaLumberjack

class RemoteViewController: UIViewController {
    
  

    @IBOutlet weak var autopilotSwitch: UISwitch!
    @IBOutlet weak var autopilotSpeed: UISlider!
    @IBOutlet weak var joystickView: JoyStickView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup joystick to update our robot command on changes
        let bundle = Bundle(for: JoyStickView.self).podResource(name: "BRHJoyStickView")
        let joystickMonitor: JoyStickViewXYMonitor = { joystickReport in
                self.joystickDidMove(joystickReport: joystickReport)
        }
        joystickView.baseImage = UIImage(named: "FancyBase", in: bundle, compatibleWith: nil)
        joystickView.handleImage = UIImage(named: "FancyHandle", in: bundle, compatibleWith: nil)
        joystickView.monitor = .xy(monitor: joystickMonitor)
        
        // Only notify us for slider speed when the user lifts their finger
        autopilotSpeed.isContinuous = false
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autopilotSwitch.isOn = RobotCommander.autopilot
    }
    
    
    private func joystickDidMove(joystickReport: JoyStickViewXYReport){
        
        // Normalize the values to be in the range zero and one
        let joyXRange = joystickView.layer.frame.width / 2.0
        let joyYRange = joystickView.layer.frame.height / 2.0
        
        let joyXNormalized = joystickReport.x / joyXRange
        let joyYNormalized = joystickReport.y / joyYRange
        
        DDLogDebug("Joystick Changed - XY: (\(joystickReport.x),\(joystickReport.y)) -> (\(joyXNormalized),\(joyYNormalized))")
        
        // Automatically disable autopilot
        autopilotSwitch.isOn = false
        
        // Set robot commander vals
        RobotCommander.groupValueUpdate(turnVal: Double(joyXNormalized), velocityVal: Double(joyYNormalized), autopilotVal: false)
    
    }
    
    @IBAction func autopilotDidChange(_ sender: Any) {
        
        // Turn auto pilot on or off and set our speed source
        let autopilotVal = autopilotSwitch.isOn
        let autoVeloVal = autopilotVal ? Double(autopilotSpeed.value) : 0.0
        
        DDLogDebug("Autopilot Switch Changed - Enabled = \(autopilotVal) Velocity = \(autoVeloVal)")
        
        // Update in one go to avoid multiple notifications
        RobotCommander.groupValueUpdate(turnVal: 0.0, velocityVal: autoVeloVal, autopilotVal: autopilotVal)
        
    
      
    }
    @IBAction func autopilotSpeedDidChange(_ sender: Any) {
        // Set our speed if the value did change
        if RobotCommander.autopilot{
            DDLogDebug("Autopilot Velocity Changed While Autopilot is Enabled.")
            RobotCommander.velocityValue = Double(autopilotSpeed.value)
        }else{
            DDLogDebug("Autopilot Velocity Changed While Autopilot is Disabled.")
        }
    }
    
}

