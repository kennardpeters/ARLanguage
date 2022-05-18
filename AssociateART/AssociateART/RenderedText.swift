//
//  RenderedText.swift
//  VisualizingSceneSemantics
/*
Used for rendering inputted strings of text as 3D objects and performing Animations on these objects using the included methods.
 */
//
//  Created by Kennard Peters on 3/22/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

class RenderedText {
    
    var text: String!
    
    var color: SimpleMaterial.Color!
    var modelE: ModelEntity!
    
    //Creates a new text entity based on inputted color and text
    required init(text: String, color: SimpleMaterial.Color) {
        self.text = text
        self.color = color
        let font = MeshResource.Font.systemFont(ofSize: 0.2)
        let wordsMesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: font)
        
        let wordsMaterial = SimpleMaterial(color: color, isMetallic: true)
        
        self.modelE = ModelEntity(mesh: wordsMesh, materials: [wordsMaterial])
        
        // Move text geometry to the left so that its local origin is in the center
        self.modelE.position.x -= self.modelE.visualBounds(relativeTo: nil).extents.x / 2
        
        // Set up model to participate in physics simulation
        if modelE.collision == nil {
            modelE.generateCollisionShapes(recursive: true)
            modelE.physicsBody = .init()
        }
        // ... but prevent it from being affected by simulation forces for now.
        modelE.physicsBody?.mode = .kinematic
        
    }
    
    //Used for calling just methods
    required init() {
        
    }
    //Animation that "bounces" during voicover
    func pronunce(textEntity: Entity, arView: ARView, location: CGPoint) {
        if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
            //Save the entity's anchor in a variable
//            guard let textAnchor = textEntity.anchor else { return }
            //Save the entity's physics (based on anchor)
//            guard let entityP = textEntity as? HasPhysics else {
//                print("no physics")
//                return
//            }
            guard let entityP = textEntity as? HasPhysics else{
                print("physics conversion Failed")
                return
            }
            //declare a reference Entity in order to move words in relation to it
            let referenceEntity = AnchorEntity(raycastResult: result)
            //Save the original transform in relation to reference entity
            let ogTransform = textEntity.transformMatrix(relativeTo: referenceEntity)
            var wTransform = ogTransform
            //Move the word position up for half a meter
            wTransform.columns.3.y += 0.5
            
            //Move the entity to the new location
            textEntity.move(to: wTransform, relativeTo: referenceEntity, duration: 0.5, timingFunction: .easeInOut)
            
            //Delay applying physics in order to create a bounce-type action
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                //Change the physicsOrigin to tap location for gravity to move in the right direction
                arView.physicsOrigin = referenceEntity
                //Apply physics to "drop" the entity
                entityP.physicsBody?.mode = .dynamic
                
            }
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
                //Move the entity back to its original position
                textEntity.move(to: ogTransform, relativeTo: referenceEntity, duration: 0.5, timingFunction: .easeInOut)
                //Make the entity static once again
                entityP.physicsBody?.mode = .kinematic
                
            }
        }
    }
    
    //Adds animation when you delete a text object
    func deleteEntity(tapEntity: Entity) {
        //Check if tapped entity has physics
        guard let model = tapEntity as? HasPhysics else {
            print("no physics")
            return
        }
        //Sace the entity's anchor
        guard let tapAnchor = tapEntity.anchor else {
            print("anchor not found")
            return
        }
        
        //Create a new variable to store location params
        var newTransform = tapAnchor.transform
        //Shrink the text when deleted:
        newTransform.scale = [0.2, 0.2, 0.2]
        //Plug transform parameters into move animation
        model.move(to: newTransform, relativeTo: tapAnchor, duration: 0.5, timingFunction: .easeInOut)
        //Make the physics dynamic after 0.25 seconds
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { (timer) in
            //Make the physics body dynamic before deletion
            model.physicsBody?.mode = .dynamic
        }
        //remove the anchor from the scene after 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            tapAnchor.removeChild(tapEntity)
        }
        
    }
    
}
