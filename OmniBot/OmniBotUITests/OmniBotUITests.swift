//
//  OmniBotUITests.swift
//  OmniBotUITests
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import XCTest

class OmniBotUITests: XCTestCase {
    
    var app:XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testJoystickMovement(){
        
        let remotecontroljoystickElement = app/*@START_MENU_TOKEN@*/.otherElements["RemoteControlJoystick"]/*[[".otherElements[\"Joystick\"]",".otherElements[\"RemoteControlJoystick\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let steeringImage = app.images["SteeringImage"]
        
        // Turn off auto pilot
         let autopilotEnableSwitch = app.switches["AutopilotEnableSwitch"]
         let switchEnableStatus = autopilotEnableSwitch.isOn ?? false
         if  switchEnableStatus{
            autopilotEnableSwitch.tap()
        }
        
        // Assert Idle conditions
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "SpeedValueLabel").label,"0.0")
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionSymbolLabel").label,"P")
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionDescriptionLabel").label,"park")
        
        // Test up/down movement
        remotecontroljoystickElement.swipeUp()
        //XCTAssertNotEqual(app.staticTexts.element(matching:.any, identifier: "SpeedValueLabel").label,"0.0")
        //XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionSymbolLabel").label,"D")
        //XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionDescriptionLabel").label,"drive")
        
        remotecontroljoystickElement.swipeDown()
        //XCTAssertNotEqual(app.staticTexts.element(matching:.any, identifier: "SpeedValueLabel").label,"0.0")
        //XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionSymbolLabel").label,"R")
        //XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "TransmissionDescriptionLabel").label,"reverse")
        
        // TODO: Test right/left movement
        remotecontroljoystickElement.swipeLeft()
        XCTAssert(steeringImage.exists)
        
        remotecontroljoystickElement.swipeRight()
        XCTAssert(steeringImage.exists)
       
        
    }
    
    func testAutopilotEnable(){
        let autopilotEnableSwitch = app.switches["AutopilotEnableSwitch"]
        let initEnableStatus = autopilotEnableSwitch.isOn ?? false
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "AutopilotStatusLabel").label,initEnableStatus ?  "On" : "Off")
        
        // Touch the switch and make sure it changes
        autopilotEnableSwitch.tap()
        let newEnabledStatus = autopilotEnableSwitch.isOn ?? false
        XCTAssertEqual(newEnabledStatus, !initEnableStatus)
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "AutopilotStatusLabel").label,newEnabledStatus ? "On" : "Off")
        
    }
    
    func testAutopilotSpeed(){
         
         // Turn on auto pilot
         let autopilotEnableSwitch = app.switches["AutopilotEnableSwitch"]
         let switchEnableStatus = autopilotEnableSwitch.isOn ?? false
         if !switchEnableStatus{
            autopilotEnableSwitch.tap()
        }
        
        // Swipe the slider all the way left then all the way right
        let autopilotspeedsliderSlider = XCUIApplication()/*@START_MENU_TOKEN@*/.sliders["AutopilotSpeedSlider"]/*[[".sliders[\"Autopilot Speed\"]",".sliders[\"AutopilotSpeedSlider\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
       
       
        autopilotspeedsliderSlider.adjust(toNormalizedSliderPosition: 0.0)
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "SpeedValueLabel").label,"0.0")
        autopilotspeedsliderSlider.adjust(toNormalizedSliderPosition: 1.0)
        XCTAssertEqual(app.staticTexts.element(matching:.any, identifier: "SpeedValueLabel").label,"1.0")
        
        
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIElement {
    var isOn: Bool? {
        return (self.value as? String).map { $0 == "1" }
    }
}
