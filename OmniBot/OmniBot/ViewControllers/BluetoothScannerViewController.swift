//
//  BluetoothScannerViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/6/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//


import UIKit
import CoreBluetooth

final class BluetoothScannerViewController: UITableViewController, UIAdaptivePresentationControllerDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    
    @IBOutlet weak var tryAgainButton: UIBarButtonItem!
    
    
//MARK: Variables
    
    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
    var progressHUD: MBProgressHUD?
    
    /// Our delegate to notify views when we dismiss
    weak var delegate: BluetoothScannerViewControllerDelegate?

    
    
//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set presentation controller as modal
        self.isModalInPresentation = true
        
        // Assign our delegates
        self.navigationController?.presentationController?.delegate = self

        // tryAgainButton is only enabled when we've stopped scanning
        tryAgainButton.isEnabled = false

        // remove extra seperator insets (looks better imho)
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // tell the delegate to notificate US instead of the previous view if something happens
        serial.delegate = self
        
        if serial.centralManager.state != .poweredOn {
            title = "Bluetooth Not Turned On"
            return
        }
        
        // start scanning and schedule the time out
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        tryAgainButton.isEnabled = true
        title = "Done Scanning"
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        if self.viewIfLoaded?.window != nil {
            Alerts.createHUD(textValue: "❌ Failed to Connect", delayLength: 1.0)
        }
    }
    
    
//MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a cell with the peripheral name as text in the label
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoundPeripheralCell")!
        let label = cell.viewWithTag(1) as! UILabel?
        label?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
    
    
//MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // the user has selected a peripheral, so stop scanning and proceed to the next view
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        serial.connectToPeripheral(selectedPeripheral!)
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD!.labelText = "Connecting..."
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
    }
    
    
//MARK: BluetoothSerialDelegate
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        tableView.reloadData()
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
                
          if self.viewIfLoaded?.window != nil {
                Alerts.createHUD(textValue: "❌ Failed to Connect", delayLength: 1.0)
        }
       
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        tryAgainButton.isEnabled = true
        
        if self.viewIfLoaded?.window != nil {
             Alerts.createHUD(textValue: "❌ Failed to Connect", delayLength: 1.0)
        }
      

    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        if let hud = progressHUD {
            hud.hide(false)
        }
                
        // Ask if we want to set the default peripheral name if it is different
        if serial.connectedPeripheral!.name != UserSettings.defaultBluetoothPeripheral, let periphName = serial.connectedPeripheral!.name{
              changeDefaultPeripheralName(newName: periphName)
        }else{
            // Close the main view
            self.cancel(self)
        }
       
        
      
    }
    
    func serialDidChangeState() {
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func changeDefaultPeripheralName(newName:String){
        // If we are not scanning display a two option alert to disconnect
       let twoOptionAlert = UIAlertController(title: "📲 New Default Peripheral", message: "You have connected to a new BLE peripheral named \(newName). Would you like to set it as your default BLE peripheral?" ,preferredStyle: UIAlertController.Style.alert)
             
             twoOptionAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
                UserSettings.defaultBluetoothPeripheral = newName
                Alerts.createHUD(textValue: "✅ Default Peripheral Changed to: \(newName)", delayLength: 1.0)
                twoOptionAlert.dismiss(animated: true, completion: nil)
                self.cancel(self)
             }))
             twoOptionAlert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
                 twoOptionAlert.dismiss(animated: true, completion: nil)
                 self.cancel(self)
             }))
         self.present(twoOptionAlert, animated: true, completion: nil)
    }
    

//MARK: IBActions
    
    @IBAction func cancel(_ sender: AnyObject) {
        // Stop scan
        serial.stopScan()
        
        // Call our completion delegate upon dismissal
        dismiss(animated: true, completion: {
            self.delegate?.bluetoothScannerViewControllerDidFinish(self)
        })
    }
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
          print("presentationControllerDidAttemptToDismiss")
          self.cancel(self)
      }

    @IBAction func tryAgain(_ sender: AnyObject) {
        // empty array an start again
        peripherals = []
        tableView.reloadData()
        tryAgainButton.isEnabled = false
        title = "Scanning..."
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(BluetoothScannerViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
  
    
}

