/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import RealityKit
import ARKit
import AVFoundation
import CoreData

class ViewController: UIViewController, ARSessionDelegate, UIPickerViewDelegate, UIPickerViewDataSource, AVSpeechSynthesizerDelegate {
    
    @IBOutlet var arView: ARView!
    //Text Input Box
    @IBOutlet weak var Text: UITextView!
    //Color picker UI element
    @IBOutlet weak var colorPicker: UIPickerView!
    //Delete button outlet
    @IBOutlet weak var deleteButton: UIButton!
    //Delete button action (While button is pressed, you delete entities rather than adding them)
    @IBAction func Delete(_ sender: Any) {
        if(deleteButton.isSelected == false){
        deleteButton.isSelected = true
        }
        else {
            deleteButton.isSelected = false
        }
    }
    //holds the class related to 3D text
    var words: RenderedText!
    
    //Need to assign in order to interface with core data model
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //########################
//    var vinyl = try! Vinyl.loadScene()
    var originA: ImageOrigin?
    //#########################
    //variable to store speech synthesizer (Need a global declaration to prevent doublespeak)
    var synthesizer: AVSpeechSynthesizer!
    
    
    //variable to hold current color selected
    var color: String!
    
    //Used for pick color method
    let colorP = colorStr()
    
    //A view that presents visual instructions that guide the user during session initialization and recovery.
    let coachingOverlay = ARCoachingOverlayView()
    
    // Cache for 3D text geometries representing the classification values.
    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]
    
    var dbh: DataHelper?

    /// - Tag: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dbh = DataHelper(context: self.context)
        self.dbh?.fetchMEC()
        
   
        //Add image anchor to scene
//        Vinyl.loadSceneAsync(completion: { (result) in
//            do {
//                let vinyl = try result.get()
//                self.arView.scene.anchors.append(vinyl)
//                let vinylH = vinyl as HasAnchoring
//                print(vinylH)
//                self.originA = ImageOrigin(imageAnchor: vinylH)
//            } catch {
//                print("error loading")
//            }
//        })
        
//        let vinyl = try! Vinyl.loadScene()
//        arView.scene.addAnchor(vinyl)
//        //convert rc scene to generic type HasAnchoring
//        let vinylH = vinyl as HasAnchoring
//        //Set the origin Anchor to vinyl Anchor
//        self.originA = ImageOrigin(imageAnchor: vinylH, arView: self.arView)
        //####
        
        let pac = try! Pac.loadScene()
        arView.scene.addAnchor(pac)
        let pacH = pac as HasAnchoring
        
        self.originA = ImageOrigin(imageAnchor: pacH, arView: self.arView, dataHelper: self.dbh!, entityIds: [:])
        
        //Ressamble previous scene based off data in Core Data db
        self.originA?.reassemble()
        
        self.synthesizer = AVSpeechSynthesizer()
        
        synthesizer.delegate = self
        
        //Class that abstracts NLP and AVSPeech details
        let TextToSpeech = TTS(speechStr: "Let's Augment Reality Together", synthesizer: self.synthesizer)
        TextToSpeech.utterance.volume = 1.0
        //Plays pronunciation
        TextToSpeech.pronounce()
        
        
        //Make the text box mutable
        Text.isEditable = true
        
        //Add done button in order to hide keyboard
        self.Text.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        // COLORS
        //Connect Data:
        self.colorPicker.delegate = self
        self.colorPicker.dataSource = self
        
        arView.session.delegate = self
        
        setupCoachingOverlay()

        arView.environment.sceneUnderstanding.options = []
        
        // Turn on occlusion in order to omit virtual text that are located behind any part of the meshed, real world
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.physics)
        
        //Turn on lighting in the scene
        arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
        
        //Turn on collision inside the environment
        arView.environment.sceneUnderstanding.options.insert(.collision)

        // Display a debug visualization of the mesh.
        arView.debugOptions.insert(.showSceneUnderstanding)
//        arView.debugOptions.insert(.showAnchorOrigins)
        
        // For performance, disable render options that are not required for this app.
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        // Manually configure what kind of AR session to run since
        // ARView on its own does not turn on mesh classification.
        
        /*
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification

        configuration.environmentTexturing = .automatic
        
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "BTIVinyl", bundle: nil) {
            configuration.maximumNumberOfTrackedImages = 1
            configuration.detectionImages = referenceImages
            configuration.automaticImageScaleEstimationEnabled = true
            
            
        }
        arView.session.run(configuration)
         */
        
        //Add Gestures to view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        //decrease duration until recognition
        longTapRecognizer.minimumPressDuration = 0.5
        //empty for now
//        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        //####################################
        arView.addGestureRecognizer(tapRecognizer)
        arView.addGestureRecognizer(longTapRecognizer)
//        arView.addGestureRecognizer(pinchRecognizer)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Hides keyboard when triggered
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    /// Places virtual-text of the classification at the touch-location's real-world intersection with a mesh.
    /// Note - because classification of the tapped-mesh is retrieved asynchronously, we visualize the intersection
    /// point immediately to give instant visual feedback of the tap.
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        //Collect tap location
        let tapLocation = sender.location(in: arView)
        //If delete button is pressed, delete what is pressed
        if(self.deleteButton.isSelected==true) {
            
            self.originA?.delete(location: tapLocation)
            
        }
        //Place a new text entity
        else {
            
            if self.color == nil {
                self.color = "Purple"
            }
            //places text in a way that faces the camera
            self.originA?.placeText(location: tapLocation, textStr: self.Text.text, textColor: self.color)
        }
    }
    //Make a function and place it as a method in Image Origin?
    @objc func longTap(_ sender: UILongPressGestureRecognizer) {
        //Save tapLocation
        let tapLocation = sender.location(in: arView)
        
        self.originA?.longTapSpeech(location: tapLocation, synthesizer: self.synthesizer)
        
    }

    //Nothing at the moment
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
    }
    
    //APPLE: Shows/Hides the mesh
    @IBAction func toggleMesh(_ button: UIButton) {
        let isShowingMesh = arView.debugOptions.contains(.showSceneUnderstanding)
        if isShowingMesh {
            arView.debugOptions.remove(.showSceneUnderstanding)
            button.setTitle("Show Mesh", for: [])
        } else {
            arView.debugOptions.insert(.showSceneUnderstanding)
            button.setTitle("Hide Mesh", for: [])
        }
    }
    
    
    
    //APPLE function that performs error handeling
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
//                self.resetButtonPressed(self)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //For color picker ########################
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.colorP.pickerData.count
    }
    
    //The data to return for the row and component(column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.colorP.pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // This method is triggered whenever the user makes a change to the picker selection.
       // The parameter named row and component represents what was selected.
        self.color = self.colorP.pickerData[row]
   }
    
}
