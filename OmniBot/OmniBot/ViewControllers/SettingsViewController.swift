//
//  SettingsViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/24/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController:UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var peripheralTextField: UITextField!
    @IBOutlet weak var transModeTextField: UITextField!
    @IBOutlet weak var autoconnectSwitch: UISwitch!
    @IBOutlet weak var transTimeSlider: UISlider!
    @IBOutlet weak var transTimeLabel: UILabel!
    @IBOutlet weak var confirmGestureSwitch: UISwitch!
    var transModePicker = UIPickerView()
    let transModeOptions:[BluetoothMode] = [.continuousUpdate,.delayedUpdate,.instantUpdate]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transModeTextField.inputView = transModePicker
        transModeTextField.tintColor = .clear
        transModePicker.delegate = self
        transModePicker.dataSource = self
    
        self.setupHideKeyboardOnTap()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        reloadView()
    }
    
    func reloadView(){
         peripheralTextField.text = UserSettings.defaultBluetoothPeripheral
         transModeTextField.text = UserSettings.bluetoothMode.rawValue
         autoconnectSwitch.isOn = UserSettings.autoConnect
         transTimeSlider.isEnabled = (UserSettings.bluetoothMode != .instantUpdate)
         if !transTimeSlider.isEnabled { transTimeSlider.value = 0.0}
         transTimeSlider.value = Float(UserSettings.bluetoothTime)
         transTimeLabel.text = String(format: "%.1f",transTimeSlider.value)
         confirmGestureSwitch.isOn = UserSettings.confirmGesture
       
    }
    
    @IBAction func timeSliderDidChange(_ sender: Any) {
        if UserSettings.bluetoothTime != Double(transTimeSlider.value)
        {
            UserSettings.bluetoothTime = Double(transTimeSlider.value)
            reloadView()
        }
       

    }
    
    
    @IBAction func peripheralDidEndEditing(_ sender: Any) {
        if let peripheralName = peripheralTextField.text{
          UserSettings.defaultBluetoothPeripheral = peripheralName
        }
         reloadView()
    }
 
    @IBAction func autoconnectDidEndEditing(_ sender: Any) {
        UserSettings.autoConnect = autoconnectSwitch.isOn
        reloadView()
    }
    @IBAction func confirmGestureDidChange(_ sender: Any) {
        UserSettings.confirmGesture = confirmGestureSwitch.isOn
        reloadView()
    }
}

extension SettingsViewController{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transModeOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return transModeOptions[row].rawValue
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedTransMode = transModeOptions[row]
            if selectedTransMode != UserSettings.bluetoothMode{
                UserSettings.bluetoothMode = selectedTransMode
                reloadView()
            }
           
    }
}
