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
    
    
    /// Notificaiton center instance
    static private let notificationCenter : NotificationCenter = .default
    
   
    /// A value between -1.0 (left full turn) and 1.0 (right full turn)
    static var turnValue:Double = 0.0{ didSet{
        turnValue = min(max(turnValue,-TURNING_LIMIT_X),TURNING_LIMIT_X)
        if turnValue != oldValue{
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.steeringChanged)
        }}
    }
    
    /// A value between -1.0 (backwards full velocity) and 1.0 (forwards full velocity)
    static var velocityValue:Double = 0.0{ didSet{
        velocityValue = min(max(velocityValue,-SPEED_LIMIT_Y),SPEED_LIMIT_Y)
        if velocityValue != oldValue {
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.velocityChanged)
        }}}
    
    /// Whether we will operate in autonmous mode
    static var autopilot:Bool = false{  didSet{
        if autopilot != oldValue{
            notificationCenter.post(name: .commanderChanged, object: ChangeTrigger.autopilotChanged)
        }
    }}
    
}

/// Extension for convenience vars
extension RobotCommander{
     
    /// Convenience attributes for accessing values of the class
     static var speedValue:Double{ return abs(velocityValue) }
     static var speedMetersSec:Double{ return speedValue * SPEED_LIMIT_METERS_SEC }
     static var speedMilesHour:Double { return speedMetersSec * 2.23694 }
     static var turnMagnitude:Double{ return abs(turnValue) }
     static var turnAngle:Double{ return turnValue * 90.0 }
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
         if turnValue < 0.0 { return .left }
         else if turnValue > 0.0 { return .right }
         else{ return .center }
     }
     static var driveDirection:DriveDirection
     {
         if velocityValue < 0.0 { return .reverse }
         else if velocityValue > 0.0 { return .drive }
         else{ return .park }
     }
    
     /// A Bluetooth command string to be sent to the arduino
     static var asBluetoothCommand:String
     {
         return "CMD:\(String(format: "%.2f", turnValue)),\(String(format: "%.2f", velocityValue)),\(autopilot)"
     }
     
      /// A dictionary representaiton of our values
     static var asDictionary:[String:Any]
     {
         return ["velocity":velocityValue,
                 "turning":turnValue,
                 "autopilot":autopilot]
     }
}

/// Extension for enums
extension RobotCommander{
    enum ChangeTrigger{
           case velocityChanged
           case steeringChanged
           case autopilotChanged
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
    }
}




extension Notification.Name {
    static var commanderChanged: Notification.Name {
        return .init(rawValue: "RobotCommander.commanderChanged")
    }
}
