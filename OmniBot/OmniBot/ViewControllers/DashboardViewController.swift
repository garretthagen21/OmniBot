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

class DashboardViewController : UIViewController,BluetoothSerialDelegate,BluetoothScannerViewControllerDelegate
{
    
    
    
    static var commonViewLoaded = false
    
    
    /// UI Outlets
    @IBOutlet weak var bluetoothStatusImage: UIImageView!
    @IBOutlet weak var bluetoothStatusLabel: UILabel!
    @IBOutlet weak var speedValueLabel: UILabel!
    @IBOutlet weak var speedUnitsLabel: UILabel!
    @IBOutlet weak var steeringImage: UIImageView!
    @IBOutlet weak var steeringLabel: UILabel!
    @IBOutlet weak var autopilotValueLabel: UILabel!
    @IBOutlet weak var autopilotDescriptionLabel: UILabel!
    @IBOutlet weak var transmissionValLabel: UILabel!
    @IBOutlet weak var transmissionTextLabel: UILabel!
    @IBOutlet weak var bluetoothStack: UIStackView!
    @IBOutlet weak var speedStack: UIStackView!
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TODO: This is being called every time the tab view changes
        print("Dashboard viewDidLoad() Triggered")
        
        // Setup gesture recognizer for bluetooth
        let bluetoothTap = UITapGestureRecognizer(target: self, action: #selector(self.handleBluetoothTap(_:)))
        bluetoothStack.addGestureRecognizer(bluetoothTap)
        
        // Setup gesture recognizer for bluetooth
         let bluetoothHold = UILongPressGestureRecognizer(target: self, action: #selector(self.handleBluetoothHold(_:)))
         bluetoothStack.addGestureRecognizer(bluetoothHold)
        
        bluetoothStack.isUserInteractionEnabled = true
        
        // Setup gesture recognizer for speed units
        let speedTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSpeedTap(_:)))
        speedStack.addGestureRecognizer(speedTap)
        speedStack.isUserInteractionEnabled = true
        
      
        // Add commander observer
        NotificationCenter.default.addObserver(self,
            selector: #selector(commanderDidChange),
            name: .commanderChanged,
            object: nil
        )
        
        // Add bluetooth observer
        NotificationCenter.default.addObserver(self,
            selector: #selector(bluetoothDidChange),
            name: .bluetoothStatusChanged,
            object: nil
        )
        // Init the bluetooth delegate to us. Note this is a hack to avoid duplicate calls
        if(!DashboardViewController.commonViewLoaded){
            serial = BluetoothSerial(delegate: self)
        }
        
        // We have loaded the common view to avoid BT interrupts (this is a a hack)
        DashboardViewController.commonViewLoaded = true
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         print("Dashboard viewDidAppear() Triggered")
        
        // Set the delegate to ourselves since we are in visible view
        serial.delegate = self
        
        // Auto connect on startup
        if !serial.isReady && !serial.isScanning
        {
           startScanning()
        }
        
        // Show BT Status
        updateBluetoothStatus()
    }
    
    /// Delegate function for when we return from scanner
    func bluetoothScannerViewControllerDidFinish(_ bluetoothScannerVC: BluetoothScannerViewController) {
        print("bluetoothScannerViewControllerDidFinish called")
        viewDidAppear(true)
    }
    
    
    
    func serialDidReceiveString(_ message: String) {
        
        print("[serialDidReceiveString] Recieved Bluetooth String: \(message)")
        
        // TODO: Add UI elements to display proximities
        let incomingString = message.components(separatedBy: ":")
     
        
        if incomingString.count != 2{
            return
        }
    }
    
    /// Triggered when user holds bluetooth
    @objc private func handleBluetoothHold(_ sender: UITapGestureRecognizer)
    {
        // Only segue at beginning of gesture
        if sender.state == UIGestureRecognizer.State.began{
            print("Bluetooth Held")
           
            
            // Assign us as the delegate
            let scannerVC = BluetoothScannerViewController.instantiateFromAppStoryboard(appStoryboard: .BluetoothScanner)
            scannerVC.delegate = self
            
            // Move to scanner view
            self.performSegue(withIdentifier: Segues.BluetoothScannerSegue.rawValue, sender: self)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.BluetoothScannerSegue.rawValue, let scannerNC = segue.destination as? UINavigationController{
            // Stop scanning
            self.scanTimeOut()
            
            // Set the scanner delegate to us
            if let scannerVC = scannerNC.viewControllers.first as? BluetoothScannerViewController{
                 scannerVC.delegate = self
            }
           
        }
    }

    /// Triggered when user taps bluetooth
    @objc private func handleBluetoothTap(_ sender: UITapGestureRecognizer) {
        print("Bluetooth Tapped")
        
        // Start scan if we are not connected
        if !serial.isReady && !serial.isScanning
        {
            startScanning()
        }
        else if !serial.isScanning{
            // If we are not scanning display a two option alert to disconnect
            let twoOptionAlert = UIAlertController(title: "😨 Disconnect", message: "Are you sure you want to disconnect from  \(serial.connectedPeripheral?.name ?? "Unknown Device")?" ,preferredStyle: UIAlertController.Style.alert)
                  
                  twoOptionAlert.addAction(UIAlertAction(title: "Disconnect", style: UIAlertAction.Style.default, handler: { (action) in
                      twoOptionAlert.dismiss(animated: true, completion: nil)
                      RobotCommander.emergencyStop()
                      serial.disconnect()
                  }))
                  twoOptionAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
                      twoOptionAlert.dismiss(animated: true, completion: nil)
                      
                  }))
                  self.present(twoOptionAlert, animated: true, completion: nil)
            
        }
    }
    
    /// Triggered when user taps speed
    @objc private func handleSpeedTap(_ sender: UITapGestureRecognizer) {
        // If the text is mph toggle to mps
        if self.speedUnitsLabel.text == "mph"{
            self.speedUnitsLabel.text = "mps"
            self.speedValueLabel.text =  String(format: "%.1f", RobotCommander.speedMetersSec)
        }
        else{
            self.speedUnitsLabel.text = "mph"
            self.speedValueLabel.text =  String(format: "%.1f", RobotCommander.speedMilesHour)
        }
          
    }
       
    
    /// Triggered when our bluetooth status changes
    @objc private func bluetoothDidChange(_ notification: Notification) {
          if let bluetoothStatus = notification.object as? BluetoothStatus{
            bluetoothStatusLabel.text = bluetoothStatus.description
            bluetoothStatusLabel.textColor = bluetoothStatus.color
            bluetoothStatusImage.image = bluetoothStatus.image
          }
       }
    
    /// Triggered when the robot state is changed (could be set by any view controller)
    @objc private func commanderDidChange(_ notification: Notification) {
        if let changeTrigger = notification.object as? RobotCommander.ChangeTrigger{
            // TEMPORARY
            
            // Update speed values
            speedValueLabel.text = String(format: "%.1f",self.speedUnitsLabel.text == "mph" ? RobotCommander.speedMilesHour : RobotCommander.speedMetersSec)
            
            // Rotate our steering image
            steeringImage.rotate(degrees: CGFloat(RobotCommander.compassOrientation))
            
            // Update autopilot status
            autopilotValueLabel.text = RobotCommander.autopilot ? "On" : "Off"
            
            // Update transmission labels
            transmissionValLabel.text = RobotCommander.driveDirection.symbol
            transmissionTextLabel.text = RobotCommander.driveDirection.description
            
            // Set a pending message
            if serial.isReady{
                serial.setPendingMessage(RobotCommander.asBluetoothCommand)
            }
         
        }
     }
    



}

/// Handles Bluetooth autoconnection functionality of our dashboard
extension DashboardViewController
{
    
    
    enum BluetoothStatus:String{
        case off = "off"
        case disconnected = "disconnected"
        case scanning = "scanning"
        case connecting = "connecting"
        case connected = "connected"
        case ready = "ready"
   
        
        var description:String{
            return self.rawValue
        }
        var color:UIColor{
            switch(self)
            {
            case .off:
                return .label
            case .disconnected:
                return .systemRed
            case .scanning:
                return .systemOrange
            case .connecting:
                return .systemOrange
            case .connected:
                return .systemYellow
            case .ready:
                return .systemGreen
            }
        }
        
        var image:UIImage{
            switch(self){
                case .off:
                    return UITraitCollection.current.userInterfaceStyle == .dark ? UIImage(named:  "icons8-bluetooth-white-100")! :     UIImage(named:  "icons8-bluetooth-black-100")!
                 case .disconnected:
                     return UIImage(named:  "icons8-bluetooth-red-100")!
                 case .scanning:
                      return UIImage(named:  "icons8-bluetooth-orange-100")!
                 case .connecting:
                     return UIImage(named:  "icons8-bluetooth-orange-100")!
                 case .connected:
                     return UIImage(named:  "icons8-bluetooth-yellow-100")!
                 case .ready:
                     return UIImage(named:  "icons8-bluetooth-green-100")!
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
        serial.disconnect()
        serial.startScan()
        updateBluetoothStatus()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DashboardViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        // Print debugging message
        print("[serialDidDiscoverPeripheral] Discovered Peripheral --> Name: \(peripheral.name ?? ""), Services: \(peripheral.services ?? [])")
        
        // TODO: Remove this once we add peripheral options
        let isDSDTECH = peripheral.name == "DSD TECH";
        if UserSettings.defaultBluetoothPeripheral == peripheral.name ?? "" || isDSDTECH{
            // Stop the current scan and begin connecting procedure
            Alerts.createHUD(textValue: "✅ Found Default Peripheral: \(UserSettings.defaultBluetoothPeripheral)", delayLength: 2.0)
            serial.stopScan()
            serial.connectToPeripheral(peripheral)
            updateBluetoothStatus()
            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DashboardViewController.connectTimeOut), userInfo: nil, repeats: false)
        }
    }
    
       
    
}



