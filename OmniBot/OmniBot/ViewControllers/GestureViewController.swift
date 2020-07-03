//
//  SecondViewController.swift
//  OmniBot
//
//  Created by Garrett Hagen on 6/1/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class GestureViewController: UIViewController, ARSCNViewDelegate {
    
    /// An enumeration representing our possible outcomes
    enum HandGesture:String, CaseIterable{
        case closedFist = "closed-fist" // TODO: maybe make closed fist a reset?
        case okSign = "ok-sign"
        case aloha = "aloha-sign"
        case flatHand = "flat-hand"
        case peace = "peace-sign"
        case tuckedThumb = "tucked-thumb"
        case rockOn = "rock-on"
        case noDetection = "Negative"
        
        var symbol:String{
            switch(self){
                case .closedFist: return "👊"
                case .okSign: return "👌"
                case .aloha: return "🤙"
                case .flatHand: return "✋"
                case .peace: return "✌️"
                case .tuckedThumb: return "✊"
                case .rockOn: return "🤘"
                case .noDetection: return "⛔️"
            }
        }
        
        var description:String{
                switch(self){
                   case .closedFist: return "Closed Fist"
                   case .okSign: return "Ok"
                   case .aloha: return "Aloha"
                   case .flatHand: return "Open Hand"
                   case .peace: return "Peace"
                   case .tuckedThumb: return "Tucked Thumb"
                   case .rockOn: return "Rock On"
                   case .noDetection: return "No Detection"
               }
        }
        
        var action:String{
              switch(self){
                     case .closedFist: return "Reset"
                     case .okSign: return "Turn Right"
                     case .aloha: return "Turn Left"
                     case .flatHand: return "Speed Up"
                     case .rockOn: return "Slow Down"
                     case .peace: return "Toggle Autopilot"
                     case .tuckedThumb: return "Stop"
                     case .noDetection: return "No Detection"
                 }
        }
        
        func applyToRobot(){
            // TODO: Might not want to apply more than once
        }
    }
    
    @IBOutlet weak var gestureOptionView: GestureOptionView!
    @IBOutlet weak var ARVideoSceneView: ARSCNView!
    @IBOutlet weak var gestureOptionsButton: UIButton!
    
    /// Asynchronus dispatch queue for ML udpates
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    
    /// Our vision request list
    var visionRequests = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure gesture options
        gestureOptionsButton.layer.borderWidth = 1.0
        gestureOptionsButton.layer.borderColor = .init(srgbRed: 175, green: 175, blue: 175, alpha: 1.0)
        gestureOptionView.setOptions(gestureOptions: HandGesture.allCases)
        gestureOptionView.isHidden = true
        
        // Set the scene view delegate
        ARVideoSceneView.delegate = self
                
        // Assign a new scene to our view
        ARVideoSceneView.scene = SCNScene()
        
              
          // Setup Vision Model
          guard let selectedModel = try? VNCoreMLModel(for: handgestures().model) else {
              fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project. Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
          }
          
          // Set up Vision-CoreML Request
          let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
          classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
          visionRequests = [classificationRequest]
            
          // Begin Loop to Update CoreML
          loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          // Create a session configuration
          let configuration = ARWorldTrackingConfiguration()

          // Run the view's session
          ARVideoSceneView.session.run(configuration)
      }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         // Pause the view's session
         ARVideoSceneView.session.pause()
     }
    
    // MARK: - ARSCNViewDelegate
       
       func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
           DispatchQueue.main.async {
               // Do any desired updates to SceneKit here.
           }
       }
       
       /// This runs in the background to update our gesture recognition
       func loopCoreMLUpdate() {
           // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
           dispatchQueueML.async {
               // 1. Run Update.
                self.updateCoreML()
               // 2. Loop this function.
                self.loopCoreMLUpdate()
           }
       }
       
       func updateCoreML() {
           // Get Camera Image as RGB and make sure it is valid
        if let pixbuff : CVPixelBuffer? = (ARVideoSceneView.session.currentFrame?.capturedImage){
                // Convert to an image
                let ciImage = CIImage(cvPixelBuffer: pixbuff!)
                
                // Prepare CoreML/Vision Request
                let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                
                // Run Vision Image Request
                do {
                    try imageRequestHandler.perform(self.visionRequests)
                } catch {
                    print(error)
                }
          
        }
    
    
       }
       
       func classificationCompleteHandler(request: VNRequest, error: Error?) {
           // Catch Errors
           if error != nil {
               print("Error: " + (error?.localizedDescription)!)
               return
           }
           guard let observations = request.results else {
               print("No results")
               return
           }
           
           // Get Classifications
           let classifications = observations[0...2] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
               .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
               .joined(separator: "\n")
           
           // Render Classifications
           DispatchQueue.main.async {
         
               
               // Display Top Symbol
               let topPrediction = classifications.components(separatedBy: "\n")[0]
               let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
               // Only display a prediction if confidence is above 1%
               let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
               if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                  // TODO: Convert to enum and display
                  print("Prediction: \(topPredictionName)")
               }
               
               // self.textOverlay.text = symbol
               
           }
       
       }
    
    /// To hide/show the gesture options
    @IBAction func didTapGestureOptions(_ sender: Any) {
        if gestureOptionView.isHidden{
            gestureOptionView.isHidden = false
            gestureOptionsButton.backgroundColor = UIColor.darkText
        }
        else{
             gestureOptionView.isHidden = true
             gestureOptionsButton.backgroundColor = UIColor.clear
        }
    }
    

}

