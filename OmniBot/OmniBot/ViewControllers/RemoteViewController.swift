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
    
    struct RobotValues{
        var velocityVal:Double
        var turnVal:Double
        var autopilotVal:Bool
    }

    @IBOutlet weak var autopilotSwitch: UISwitch!
    @IBOutlet weak var autopilotSpeed: UISlider!
    @IBOutlet weak var joystickView: JoyStickView!
    private var joystickTimer:Timer?
    private var pendingValues:RobotValues?
    private let pendWaitTime:Double = 0.01
    
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
    
    
    private func joystickDidMove(joystickReport: JoyStickViewXYReport){
        
        // Normalize the values to be in the range zero and one
        let joyXRange = joystickView.layer.frame.width / 2.0
        let joyYRange = joystickView.layer.frame.height / 2.0
        
        let joyXNormalized = joystickReport.x / joyXRange
        let joyYNormalized = joystickReport.y / joyYRange
        
        // print("Joystick XY: (\(joystickReport.x),\(joystickReport.y)) -> (\(joyXNormalized),\(joyYNormalized))")
        
        // Automatically disable autopilot
        autopilotSwitch.isOn = false
        
        // NOTE: The code below aims to only apply updates when the user reaches the end of their joystick movement
        // which will help to avoid clobbering the bluetooth channel with intermediate joystick values
        
        // Invalidate the current timer
        joystickTimer?.invalidate()
        
        // Set our pending values which will be sent if the timer runs out
        pendingValues = RobotValues(velocityVal: Double(joyXNormalized), turnVal:  Double(joyYNormalized), autopilotVal: false)
        
        // Reset the timer to trigger after 0.1 seconds (e.g. the user must not move the joystick for atleast 0.1 secs)
        joystickTimer = Timer.scheduledTimer(timeInterval: pendWaitTime, target: self, selector: #selector(RemoteViewController.joystickDidSettle), userInfo: nil, repeats: false)
  
       
    }
    @objc func joystickDidSettle()
    {
        if let pendVals = pendingValues{
            RobotCommander.groupValueUpdate(turnVal: pendVals.turnVal, velocityVal: pendVals.velocityVal, autopilotVal: pendVals.autopilotVal)
        }
    }
    @IBAction func autopilotDidChange(_ sender: Any) {
        // Turn auto pilot on or off and set our speed source
        let autopilotVal = autopilotSwitch.isOn
        let autoVeloVal = autopilotVal ? Double(autopilotSpeed.value) : 0.0
        
        // Update in one go to avoid multiple notifications
        RobotCommander.groupValueUpdate(turnVal: 0.0, velocityVal: autoVeloVal, autopilotVal: autopilotVal)
        
    
      
    }
    @IBAction func autopilotSpeedDidChange(_ sender: Any) {
        // Set our speed if the value did change
        if RobotCommander.autopilot{
            RobotCommander.velocityValue = Double(autopilotSpeed.value)
        }
    }
    
}

