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

    @IBOutlet weak var ARVideoSceneView: ARSCNView!
    
    /// Asynchronus dispatch queue for ML udpates
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    
    /// Our vision request list
    var visionRequests = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scene view delegate
        ARVideoSceneView.delegate = self
                
        // Assign a new scene to our view
        ARVideoSceneView.scene = SCNScene()
        
              
      /* Setup Vision Model
      guard let selectedModel = try? VNCoreMLModel(for: example_5s0_hand_model().model) else {
          fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project. Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
      }
      
      // Set up Vision-CoreML Request
      let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
      classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
      visionRequests = [classificationRequest]
         */
      
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
                
                /* Run Vision Image Request
                do {
                    try imageRequestHandler.perform(self.visionRequests)
                } catch {
                    print(error)
                }
                */
            
            
            
        }
    
    
       }
       
       func classificationCompleteHandler(request: VNRequest, error: Error?) {
           /* Catch Errors
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
               .flatMap({ $0 as? VNClassificationObservation })
               .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
               .joined(separator: "\n")
           
           // Render Classifications
           DispatchQueue.main.async {
               // Print Classifications
                   // print(classifications)
                   // print("-------------")
               
               // Display Debug Text on screen
               self.debugTextView.text = "TOP 3 PROBABILITIES: \n" + classifications
               
               // Display Top Symbol
               var symbol = "❎"
               let topPrediction = classifications.components(separatedBy: "\n")[0]
               let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
               // Only display a prediction if confidence is above 1%
               let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
               if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                   if (topPredictionName == "fist-UB-RHand") { symbol = "👊" }
                   if (topPredictionName == "FIVE-UB-RHand") { symbol = "🖐" }
               }
               
               self.textOverlay.text = symbol
               
           }
         */
       }
        

}

