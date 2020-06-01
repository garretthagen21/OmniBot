//
//  RobotState.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation

/// Constants for our mechanical limits
let TURNING_LIMIT:Double = 1.0
let SPEED_LIMIT:Double = 1.0

class RobotCommander
{
    /// Notificaiton center instance
    private let notificationCenter : NotificationCenter
   
    /// A value between -1.0 (left full turn) and 1.0 (right full turn)
    var turnValue:Double = 0.0{ didSet{
        turnValue = min(max(turnValue,-TURNING_LIMIT),TURNING_LIMIT)
        if turnValue != oldValue{
            commandDidChange(trigger: .steeringChanged)
        }} }
    
    /// A value between -1.0 (backwards full velocity) and 1.0 (forwards full velocity)
    var velocityValue:Double = 0.0{ didSet{
        velocityValue = min(max(velocityValue,-SPEED_LIMIT),SPEED_LIMIT)
        if velocityValue != oldValue {
            commandDidChange(trigger: .velocityChanged)
        }}}
    
    /// Whether we will operate in autonmous mode
    var autopilot:Bool = false{  didSet{
        if autopilot != oldValue{
            commandDidChange(trigger: .autopilotChanged)
        }
    }}
    
    
    /// Convenience attributes for accessing values of the class
    var speedValue:Double{ return abs(velocityValue) }
    var turnMagnitude:Double{ return abs(turnValue) }
    var steeringDirection:SteeringDirection{
        if turnValue < 0.0 { return .left }
        else if turnValue > 0.0 { return .right }
        else{ return .center }
    }
    var driveDirection:DriveDirection
    {
        if velocityValue < 0.0 { return .reverse }
        else if turnValue > 0.0 { return .forward }
        else{ return .stopped }
    }
   
    
    /// A Bluetooth command string to be sent to the arduino
    var asBluetoothCommand:String
    {
        return "CMD:\(String(format: "%.2f", turnValue)),\(String(format: "%.2f", velocityValue)),\(autopilot)"
    }
    
     /// A dictionary representaiton of our values
    var asDictionary:[String:Any]
    {
        return ["velocity":velocityValue,
                "turning":turnValue,
                "autopilot":autopilot]
    }
        
    /// Initializer for observing notifications
    init(notificationCenter: NotificationCenter = .default) {
           self.notificationCenter = notificationCenter
    }
    

    private func commandDidChange(trigger: ChangeTrigger) -> Void
    {
        switch trigger{
            case .velocityChanged:
                notificationCenter.post(name: .velocityChanged, object: self)
            case .steeringChanged:
                notificationCenter.post(name: .steeringChanged, object: self)
            case .autopilotChanged:
                notificationCenter.post(name: .autopilotChanged, object: self)
        }
    }
    
   
    
}

extension RobotCommander{
    enum SteeringDirection : Int
    {
        case right = 1
        case center = 0
        case left = -1
    }
    enum DriveDirection : Int
    {
        case forward = 1
        case stopped = 0
        case reverse = -1
    }
}

extension RobotCommander{
    enum ChangeTrigger{
        case velocityChanged
        case steeringChanged
        case autopilotChanged
    }
}


extension Notification.Name {
    static var velocityChanged: Notification.Name {
        return .init(rawValue: "RobotCommander.velocityChanged")
    }

    static var steeringChanged: Notification.Name {
        return .init(rawValue: "RobotCommander.steeringChanged")
    }

    static var autopilotChanged: Notification.Name {
        return .init(rawValue: "RobotCommander.autopilotChanged")
    }

}
