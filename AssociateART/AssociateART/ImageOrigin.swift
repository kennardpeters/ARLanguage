//
//  ImageAnchor.swift
//  outerAnimation
//
//  Created by Kennard Peters on 4/20/21.
//

import Foundation
import ARKit
import RealityKit

class ImageOrigin {
    var originAnchor: HasAnchoring
    var arView: ARView
    //Binds unique entity ID with rendered words
    var dbh: DataHelper
    var entityIds:[UInt64: UUID]
    required init(imageAnchor: HasAnchoring, arView: ARView, dataHelper: DataHelper, entityIds: [UInt64: UUID]) {
        self.originAnchor = imageAnchor
        self.arView = arView
        self.dbh = dataHelper
        self.entityIds = entityIds
        
    }
    //VC variables: self.arView, self.Text.text, self.RenderedText, self.pickcolor, self.color (Can place outside function)
    func placeText(location: CGPoint, textStr:String, textColor: String){
        // Perform a ray cast against the mesh.
        // Note: Ray-cast option ".estimatedPlane" with alignment ".any" also takes the mesh into account.
        let colorP = colorStr()
        if let result = self.arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
            
            // Compute a position for the text which is near the result location, but offset 10 cm
            // towards the camera (along the ray) to minimize unintentional occlusions of the text by the mesh.
            let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
            let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
            
//            //Retrieve User inputted text
//            guard let textStr = self.Text.text else { return }

            // Place the Anchor for the text, facing the camera.
            var resultWithCameraOrientation = self.arView.cameraTransform
            resultWithCameraOrientation.translation = textPositionInWorldCoordinates
            
            //Use for unsaved session (Away from anchor image)
            //let textAnchor = AnchorEntity(world: resultWithCameraOrientation.matrix)
            
            //Get the color from the UIPicker (Consider placing outside)
            let textColorUI = colorP.pickColor(colorStr: textColor)
            //Call the Rendered Text class in order create new entity
            let words = RenderedText(text: textStr, color: textColorUI)
            //Assign entity to a variable for convenience
            guard let modelE = words.modelE else { return }
            
            //Add string used to global dictionary for reference
            // Used for keeping track of the correct pronunciation
            //######################################
            
            //self.arView.scene.addAnchor(textAnchor)//, removeAfter: 3)
            //add the words enity to textAnchor
            self.addChildMatrix(modelE: modelE, matrix: resultWithCameraOrientation.matrix)
            let transformA = modelE.transformMatrix(relativeTo: self.originAnchor)
            //textAnchor.addChild(modelE)
            //############Test
            //typecast as entity to save ID
            let entityE = modelE as Entity
            //Assign UUID in order to enter into local dictionary
            let id = self.dbh.addData(name: textStr, color: textColor, transform: transformA)
            //Assign the word to the name
            entityE.name = textStr
            //Bind UUID to entity id in scene
            self.entityIds[entityE.id] = id
            //########################
            
            //Enable pinch to scale on entities (for scaling)
            self.arView.installGestures(.scale, for: modelE)
        }
    }
    
    public func delete(location: CGPoint){
        //Returns entity + anchor at tapped location
        let resultEntities = arView.entities(at: location)
        guard var resultEntity = arView.entity(at: location) else { return }
        var wordId: UUID?
        for entity in resultEntities {
            for word in self.dbh.entityDict {
                //if entity.name == word.word! {
                if word.id! == self.entityIds[entity.id] {
                    resultEntity = entity
                    wordId = self.entityIds[entity.id]
                    break
                }
                
            }
        }
        print(resultEntity.name)
//            guard let resultAnchor = resultEntity.anchor else { return }
        let words = RenderedText()
        //Delete Anchor with physics (Interactive behavior)
        words.deleteEntity(tapEntity: resultEntity)
        if wordId != nil {
            self.dbh.deleteData(id: wordId!)
        }
//            arView.scene.removeAnchor(resultAnchor, physics: true)
    }
    
    public func longTapSpeech(location: CGPoint, synthesizer: AVSpeechSynthesizer) {
        //Save Entity and anchor of tapLocation
        var resultEntities = self.arView.entities(at: location)
//        guard var resultEntity = arView.entity(at: tapLocation) else {
//            print("no entity")
//            return }
        var resultEntity:Entity?
        for entity in resultEntities {
            if entity.anchor?.id == self.originAnchor.id {
                resultEntity = entity
                print("EntityName: \(entity.name)")
            }
        }
        if resultEntity != nil {
            
            print("Entity id atap: \(resultEntity!.id)")
            
            
            print("Result Entity Name: \(resultEntity!.name)")
            //Get string based on entity id from entityDict

            //##########################
            var str = resultEntity!.name
            
            //############################
            print(str)
            //Calls text to speech class to configure speech setup
            let TextToSpeech = TTS(speechStr: str, synthesizer: synthesizer)
            //Plays pronunciation
            TextToSpeech.pronounce()
            let words = RenderedText()
            //Animation (Bounce for pronunciation)
            words.pronunce(textEntity: resultEntity!, arView: self.arView, location: location)
        }
    }
    
    public func addChildMatrix(modelE: Entity, matrix: float4x4) {
            //Set the position of the new entity
            modelE.setTransformMatrix(matrix, relativeTo: nil)
            //Add the newEntity to the origin anchor preserving the same location
            self.originAnchor.addChild(modelE, preservingWorldTransform: true)
        }
    
    public func addChildTap(tapLocation: CGPoint, modelE: Entity) {
        //Perform a raycast at the tap location
        if let result = self.arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
            //Set the entity's transformation matrix based off raycast result's world transform
            modelE.setTransformMatrix(result.worldTransform, relativeTo: nil)
            //Add the entity to the origin anchor preserving the World Transform
            originAnchor.addChild(modelE, preservingWorldTransform: true)
            //Need to save this data
            let transformationMat = modelE.transformMatrix(relativeTo: self.originAnchor)
            
        }
        
    }
    //Need a method to recreate object placements based on transformation Matrix
    public func reassemble()  {
//        //Params: entityDict, pickColor, RenderedText, entityId
        if self.dbh.entityDict != nil {
            let colorP = colorStr()
            //Make a function or method######
            var transformList = [simd_float4x4]()
            for mec in self.dbh.entityDict {
            //for mec in entityDict! {
                var colorT = colorP.pickColor(colorStr: mec.color)
                var wordE = RenderedText(text: mec.word!, color: colorT)
                guard let modelE = wordE.modelE else {
                    return
                }
                modelE.name = mec.word!
                //assigns transform in each MEC to a variable
                var transform = mec.transform
                //Places the transform into a 4x4 matrix
                var transfrom = transform?.expand()
                //Appends 4x4 transform to list
                transformList.append(transfrom!)
                wordE.modelE.setTransformMatrix(transfrom!, relativeTo: self.originAnchor)
                self.originAnchor.addChild(modelE)
                let entityE = modelE as Entity
                self.entityIds[entityE.id] = mec.id!
                print("entityE id bTap: \(entityE.id)")
                print("\(mec.word!): \(modelE.id)" )
            //############################
            }
        }
    }
    
}
