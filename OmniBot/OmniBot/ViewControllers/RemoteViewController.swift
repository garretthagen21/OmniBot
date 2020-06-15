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
    
    }
    
    
    private func joystickDidMove(joystickReport: JoyStickViewXYReport){
        
        // Normalize the values to be in the range zero and one
        let joyXRange = joystickView.layer.frame.width / 2.0
        let joyYRange = joystickView.layer.frame.height / 2.0
        
        let joyXNormalized = joystickReport.x / joyXRange
        let joyYNormalized = joystickReport.y / joyYRange
        
        print("Joystick XY: (\(joystickReport.x),\(joystickReport.y)) -> (\(joyXNormalized),\(joyYNormalized))")
        
        // Turn off auto pilot if it is on
        if RobotCommander.autopilot{
            print("Disabling autopilot")
            autopilotSwitch.isOn = false
            autopilotDidChange(self)
        }
        RobotCommander.turnValue = Double(joyXNormalized)
        RobotCommander.velocityValue = Double(joyYNormalized)
       
    }

    @IBAction func autopilotDidChange(_ sender: Any) {
        // Turn auto pilot on or off
        RobotCommander.autopilot = autopilotSwitch.isOn
        
        // Enable our speed control based on auto pilot
        // autopilotSpeed.isEnabled = autopilotSwitch.isOn
        
        // Set the velocity value based on our slider or disable it
        RobotCommander.velocityValue = RobotCommander.autopilot ? Double(autopilotSpeed.value) : 0.0
      
    }
    @IBAction func autopilotSpeedDidChange(_ sender: Any) {
        // Set our speed if the value did change
        if RobotCommander.autopilot{
            RobotCommander.velocityValue = Double(autopilotSpeed.value)
        }
    }
    
}

