//
//  DashboardViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class DashboardViewController : UIViewController,BluetoothSerialDelegate
{
    let AUTOCONNECT_BT_PERIPHERALS = ["DSD TECH","OmniBot"]
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign the blueooth delegate to us
        serial.delegate = self
        
        // Add velocity observer
        NotificationCenter.default.addObserver(self,
            selector: #selector(velocityDidChange),
            name: .velocityChanged,
            object: nil
        )
        // Add turning observer
        NotificationCenter.default.addObserver(self,
            selector: #selector(steeringDidChange),
            name: .steeringChanged,
            object: nil
        )
        
        // Add autopilot observer
        NotificationCenter.default.addObserver(self,
                selector: #selector(autopilotDidChange),
                name: .autopilotChanged,
                object: nil
        )
        
        // Add bluetooth status observer
        NotificationCenter.default.addObserver(self,
                selector: #selector(bluetoothDidChange),
                name: .bluetoothStatusChanged,
                object: nil
        )
    }
    
    
    func serialDidReceiveString(_ message: String) {
        let incomingString = message.components(separatedBy: ":")
        if incomingString.count != 2{
            return
        }
    }
    
    
    
    @objc private func bluetoothDidChange(_ notification: Notification) {
          if let bluetoothStatus = notification.object as? BluetoothStatus{
              // TODO: Populate speed labels and maybe animate velocity gauge or something
              // bluetoothStatusLabel.text = bluetoothStatus.description
          }
       }

    @objc private func velocityDidChange(_ notification: Notification) {
        if let commander = notification.object as? RobotCommander{
            // TODO: Populate speed labels and maybe animate velocity gauge or something
            // speedLabel.text = String(format: "%.2f", commander.speedValue)
            
        }
     }
    
    @objc private func steeringDidChange(_ notification: Notification) {
         if let commander = notification.object as? RobotCommander{
             // TODO: Populate speed labels and maybe animate velocity gauge or something
             // speedLabel.text = String(format: "%.2f", commander.speedValue)
             
         }
      }
    @objc private func autopilotDidChange(_ notification: Notification) {
         if let commander = notification.object as? RobotCommander{
             // TODO: Populate speed labels and maybe animate velocity gauge or something
             // speedLabel.text = String(format: "%.2f", commander.speedValue)
             
         }
    }


}

/// Handles Bluetooth autoconnection functionality of our dashboard
extension DashboardViewController
{
    
    
    enum BluetoothStatus:String{
        case off = "Off"
        case disconnected = "Disconnected"
        case scanning = "Scanning"
        case connecting = "Connecting"
        case connected = "Connected"
        case ready = "Ready"
   
        
        var description:String{
            return self.rawValue
        }
        var color:UIColor{
            switch(self)
            {
            case .off:
                return .systemGray
            case .disconnected:
                return .systemRed
            case .scanning:
                return .systemPink
            case .connecting:
                return .systemOrange
            case .connected:
                return .systemYellow
            case .ready:
                return .systemGreen
            }
        }
    }
    
    // Called 10s after we have begun scanning
    @objc func scanTimeOut(){
        print("[scanTimeOut] Function Called")
        serial.stopScan()
        updateBluetoothStatus()

    }
    // Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        print("[connectTimeOut] Function Called")
        updateBluetoothStatus()
    }
    
    // For UI updating purposes
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("[serialDidDisconnect] Function Called")
        updateBluetoothStatus()
        
    }
    func serialDidConnect(_peripheral: CBPeripheral){
        print("[serialDidConnect] Function Called for \(serial.connectedPeripheral?.name ?? "")")
        updateBluetoothStatus()
    }
    func serialIsReady(_ peripheral: CBPeripheral) {
        print("[serialIsReady] Function Called for \(serial.connectedPeripheral?.name ?? "")")
        updateBluetoothStatus()
    }
    func serialDidChangeState() {
        print("[serialDidChangeState] Function Called")
        updateBluetoothStatus()
    }
    
    private func updateBluetoothStatus()
    {
        
        
        if !serial.isPoweredOn {
            NotificationCenter.default.post(name: .bluetoothStatusChanged, object: BluetoothStatus.off)
        }
       else
       {
           if serial.connectedPeripheral != nil{
               if serial.isReady{
                   NotificationCenter.default.post(name: .bluetoothStatusChanged, object: BluetoothStatus.ready)
               }
               else{
                     NotificationCenter.default.post(name: .bluetoothStatusChanged, object: BluetoothStatus.connected)
               }
               
           }
           else{
            if serial.pendingPeripheral != nil{
                NotificationCenter.default.post(name: .bluetoothStatusChanged,object: BluetoothStatus.connecting)
            }
            else if serial.isScanning{
                NotificationCenter.default.post(name: .bluetoothStatusChanged,object: BluetoothStatus.scanning)

            }
            else{
                 NotificationCenter.default.post(name: .bluetoothStatusChanged, object: BluetoothStatus.disconnected)
            }
           }
       }
    }
    
    func startScanning()
    {
        // Disconnect from any current connections
        //serial.disconnect()
        serial.startScan()
        updateBluetoothStatus()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DashboardViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        // Print debugging message
        print("[serialDidDiscoverPeripheral] Discovered Peripheral --> Name: \(peripheral.name ?? "") Services: \(peripheral.services ?? [])")
        
        if AUTOCONNECT_BT_PERIPHERALS.contains(peripheral.name ?? ""){
            // Stop the current scan and begin connecting procedure
            serial.stopScan()
            serial.connectToPeripheral(peripheral)
            updateBluetoothStatus()
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DashboardViewController.connectTimeOut), userInfo: nil, repeats: false)
        }
    }
    
       
    
}


extension Notification.Name {
    static var bluetoothStatusChanged : Notification.Name{
        return .init(rawValue: "BluetoothSerial.bluetoothStatusChanged")
    }
}
