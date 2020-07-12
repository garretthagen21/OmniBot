//
//  RobotState.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation




class RobotCommander
{
    /// Constants for our mechanical limits
    static let TURNING_LIMIT_X:Double = 1.0
    static let SPEED_LIMIT_Y:Double = 1.0
    static let SPEED_LIMIT_METERS_SEC:Double = 5
    static let CHANGE_THRESH:Double = 0.0
    
    
    /// Notificaiton center instance
    static private let notificationCenter : NotificationCenter = .default
    
    /// This is used when we want to avoid sending multiple notifications if we are setting multiple attributes at the same time
    static private var notificationsEnabled = true
    
   
    /// A value between -1.0 (left full turn) and 1.0 (right full turn)
    static var turnValue:Double = 0.0{ didSet{
        turnValue = min(max(turnValue,-TURNING_LIMIT_X),TURNING_LIMIT_X)
        if notificationsEnabled && abs(turnValue - oldValue) > CHANGE_THRESH{
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.steeringChanged)
        }}
    }
    
    /// A value between -1.0 (backwards full velocity) and 1.0 (forwards full velocity)
    static var velocityValue:Double = 0.0{ didSet{
        velocityValue = min(max(velocityValue,-SPEED_LIMIT_Y),SPEED_LIMIT_Y)
        if notificationsEnabled && abs(velocityValue - oldValue) >= CHANGE_THRESH{
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.velocityChanged)
        }}}
    
    /// Whether we will operate in autonmous mode
    static var autopilot:Bool = false{  didSet{
        if notificationsEnabled && autopilot != oldValue{
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.autopilotChanged)
        }
    }}
    
    /// Set multiple values, but only send one notification for the update
    @objc static func groupValueUpdate(turnVal:Double,velocityVal:Double,autopilotVal:Bool)
    {
        // Temporarily disable sending notifications
        notificationsEnabled = false
        
        // Set our values
        turnValue = turnVal
        velocityValue = velocityVal
        autopilot = autopilotVal
        
        // Send update and reanable notificationTrigger
        notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.multipleChanged)
        notificationsEnabled = true
        
        
    }
    
}

/// Extension for convenience vars
extension RobotCommander{
     
    /// Convenience attributes for accessing values of the class
     static var speedValue:Double{ return abs(velocityValue) }
     static var speedMetersSec:Double{ return speedValue * SPEED_LIMIT_METERS_SEC }
     static var speedMilesHour:Double { return speedMetersSec * 2.23694 }
     static var turnMagnitude:Double{ return abs(turnValue) }
     static var turnAngle:Double{ return turnValue * 90.0 }
     static var cardinalDirection:String{
        // Where left/right always overrides north/south
        switch steeringDirection{
            case .center:
                return driveDirection.cardinal
            case .left,.right:
                return steeringDirection.cardinal
        }
     }
     static var compassOrientation:Double{
        switch driveDirection {
            case .drive:
                return turnAngle
            case .reverse:
                return 180 - turnAngle
            default:
                return 0.0
            }
        }
     static var steeringDirection:SteeringDirection{
         if turnValue < -0.0 { return .left }
         else if turnValue > 0.0 { return .right }
         else{ return .center }
     }
     static var driveDirection:DriveDirection
     {
         if velocityValue < 0.0 { return .reverse }
         else if velocityValue > 0.0 { return .drive }
         else{ return .park }
     }
    
     /// A Bluetooth command string to be sent to the arduino with continous values
     static var asBluetoothCommand:String
     {
        return "C:\(String(format: "%.2f", turnValue)),\(String(format: "%.2f", velocityValue)),\(autopilot ? 1 : 0)\n"
     }
    
    /* DEPRACATED
    /// A Bluetooth command string containing cardinal direction and motor speed
    static var asBluetoothCommandCardinal:String{
        return "CC:\(cardinalDirection),\(String(format: "%.2f", velocityValue)),\(autopilot ? 1 : 0)\n"
    }
     */
     
      /// A dictionary representaiton of our values
     static var asDictionary:[String:Any]
     {
         return ["velocity":velocityValue,
                 "turning":turnValue,
                 "autopilot":autopilot]
     }
    /// Convenience to apply a stop signal
    static func emergencyStop(){
        RobotCommander.groupValueUpdate(turnVal: 0.0, velocityVal: 0.0, autopilotVal: false)
    }
    
    /// Pause updates to the robot
    static func pauseControl(displayHUD:Bool = false){
        emergencyStop()
        notificationsEnabled = false
        
        if displayHUD{
            Alerts.createHUD(textValue: "⏸ Control Paused", delayLength: 2.0)
        }
    }
    /// Resume sending updates to the robot
    static func resumeControl(displayHUD:Bool = false)
    {
       notificationsEnabled = true
       emergencyStop()
        
        if displayHUD{
            Alerts.createHUD(textValue: "▶️ Control Resumed", delayLength: 2.0)
        }
    }
}

/// Extension for enums
extension RobotCommander{
    enum ChangeTrigger{
           case velocityChanged
           case steeringChanged
           case autopilotChanged
           case multipleChanged
    }
    
    enum SteeringDirection : Int
    {
        case right = 1
        case center = 0
        case left = -1
        
        var description:String{
            switch self{
            case .right:
                return "right"
            case .center:
                return "center"
            case .left:
                return "left"
            }
        }
        
        var symbol:String{
            switch self{
                   case .right:
                       return "R"
                   case .center:
                       return "S"
                   case .left:
                       return "L"
            }
        }
        
        var cardinal:String{
            switch self{
                 case .right:
                     return "E"
                 case .center:
                     return "-"
                 case .left:
                     return "W"
            }
        }
    }
    enum DriveDirection : Int
    {
        case drive = 1
        case park = 0
        case reverse = -1
        
        var description:String{
              switch self{
                  case .drive:
                      return "drive"
                  case .park:
                      return "park"
                  case .reverse:
                      return "reverse"
              }
        }
        
        var symbol:String{
            switch self{
                case .drive:
                    return "D"
                case .park:
                    return "P"
                case .reverse:
                    return "R"
            }
        }
        
        var cardinal:String{
              switch self{
                   case .drive:
                       return "N"
                   case .park:
                       return "-"
                   case .reverse:
                       return "S"
              }
        }
    }
}





