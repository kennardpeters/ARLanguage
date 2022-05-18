//
//  AppleMeshHelpers.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/28/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

class MeshHelpers {
    
    /// Places virtual-text of the classification at the touch-location's real-world intersection with a mesh.
    /// Note - because classification of the tapped-mesh is retrieved asynchronously, we visualize the intersection
    /// point immediately to give instant visual feedback of the tap.
    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        //Collect tap location
//        let tapLocation = sender.location(in: arView)
    
    // 1. Perform a ray cast against the mesh.
    // Note: Ray-cast option ".estimatedPlane" with alignment ".any" also takes the mesh into account.
//            if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
//                // ...
//                // 2. Visualize the intersection point of the ray with the real-world surface.
//                let resultAnchor = AnchorEntity(world: result.worldTransform)
//                //resultAnchor.addChild(sphere(radius: 0.01, color: .lightGray))
//
//                //Render based on initial tap (Need to transform based on wall, ceiling, verticle planes
//    //            let textStr = "孔明识"
//    //            guard let textStr = Text.text else { return  }
//    //
//    //            Need to add optionality for choosing the color of the words
//    //            let words = RenderedText(text: textStr, anchor: resultAnchor, color: .blue)
//
//                arView.scene.addAnchor(resultAnchor, removeAfter: 3)
//
//                // 3. Try to get a classification near the tap location.
//                //    Classifications are available per face (in the geometric sense, not human faces).
//                nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in
//                    // ...
//                    DispatchQueue.main.async {
//                        // 4. Compute a position for the text which is near the result location, but offset 10 cm
//                        // towards the camera (along the ray) to minimize unintentional occlusions of the text by the mesh.
//                        let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
//                        let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
//
//                        // 5. Create a 3D text to visualize the classification result.
//                        ///NOT USED ###################
//                        let textEntity = self.model(for: classification)
//                        ///####################################
//
//                        //Retrieve User inputted text
//                        guard let textStr = self.Text.text else { return }
//
//
//                        // 6. Scale the text depending on the distance, such that it always appears with
//                        //    the same size on screen.
//                        ///####### NOT USED
//                        let raycastDistance = distance(result.worldTransform.position, self.arView.cameraTransform.translation)
//                        textEntity.scale = .one * raycastDistance
//                        ///################
//
//                        // 7. Place the text, facing the camera.
//                        var resultWithCameraOrientation = self.arView.cameraTransform
//                        resultWithCameraOrientation.translation = textPositionInWorldCoordinates
//                        let textAnchor = AnchorEntity(world: resultWithCameraOrientation.matrix)
//
//    //                    textAnchor.addChild(textEntity)
//                        //Get the color from the UIPicker
//                        let textColor = self.pickColor(colorStr: self.color)
//                        //Call the Rendered Text class in order create new entity
//                        self.words = RenderedText(text: textStr, color: textColor)
//                        //Assign entity to a variable for convenience
//                        guard let modelE = self.words.modelE else { return }
//                        //Add string used to global dictionary for reference
//                        // Used for keeping track of the correct pronunciation
//                        self.entityDict[modelE.id] = textStr
//
//                        //Add the text Anchor to the Scene
//                        self.arView.scene.addAnchor(textAnchor)//, removeAfter: 3)
//                        //add the words enity to textAnchor
//                        textAnchor.addChild(modelE)
//
//                        //Enable pinch to scale on entities (for scaling)
//                        self.arView.installGestures(.scale, for: modelE)
//
//
//
//                        // 8. Visualize the center of the face (if any was found) for three seconds.
//                        //    It is possible that this is nil, e.g. if there was no face close enough to the tap location.
//    //                    if let centerOfFace = centerOfFace {
//    //                        let faceAnchor = AnchorEntity(world: centerOfFace)
//    //                        faceAnchor.addChild(self.sphere(radius: 0.01, color: classification.color))
//    //                        self.arView.scene.addAnchor(faceAnchor, removeAfter: 3)
//    //                    }
//                        }
//                    }
//            }
//
//        }
    }
    //APPLE: Used as a helper function to place Text (Deep Dive needed to save locations
    //DOES not work w/o manually configured session
//    func nearbyFaceWithClassification(to location: SIMD3<Float>, completionBlock: @escaping (SIMD3<Float>?, ARMeshClassification) -> Void) {
//        guard let frame = arView.session.currentFrame else {
//            completionBlock(nil, .none)
//            return
//        }
//
//        var meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor })
//
//        // Sort the mesh anchors by distance to the given location and filter out
//        // any anchors that are too far away (4 meters is a safe upper limit).
//        let cutoffDistance: Float = 4.0
//        meshAnchors.removeAll { distance($0.transform.position, location) > cutoffDistance }
//        meshAnchors.sort { distance($0.transform.position, location) < distance($1.transform.position, location) }
//
//        // Perform the search asynchronously in order not to stall rendering.
//        DispatchQueue.global().async {
//            for anchor in meshAnchors {
//                for index in 0..<anchor.geometry.faces.count {
//                    // Get the center of the face so that we can compare it to the given location.
//                    let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
//
//                    // Convert the face's center to world coordinates.
//                    var centerLocalTransform = matrix_identity_float4x4
//                    centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
//                    let centerWorldPosition = (anchor.transform * centerLocalTransform).position
//
//                    // We're interested in a classification that is sufficiently close to the given location––within 5 cm.
//                    let distanceToFace = distance(centerWorldPosition, location)
//                    if distanceToFace <= 0.05 {
//                        // Get the semantic classification of the face and finish the search.
//                        let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index)
//                        completionBlock(centerWorldPosition, classification)
//                        return
//                    }
//                }
//            }
//
//            // Let the completion block know that no result was found.
//            completionBlock(nil, .none)
//        }
//    }
    //APPLE: classifies mesh as floor, ceiling, table, wall, window, ... (Not used atm)
//    func model(for classification: ARMeshClassification) -> ModelEntity {
//        // Return cached model if available
//        if let model = modelsForClassification[classification] {
//            model.transform = .identity
//            return model.clone(recursive: true)
//        }
//
//        // Generate 3D text for the classification
//        let lineHeight: CGFloat = 0.05
//        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
//        let textMesh = MeshResource.generateText(classification.description, extrusionDepth: Float(lineHeight * 0.1), font: font)
////##################Use classification.description to augment position of text (ceiling, wall, floor)
//        let textMaterial = SimpleMaterial(color: classification.color, isMetallic: true)
//        let model = ModelEntity(mesh: textMesh, materials: [textMaterial])
//        // Move text geometry to the left so that its local origin is in the center
//        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
//        // Add model to cache
//        modelsForClassification[classification] = model
//        return model
//    }
    
//    //APPLE: Helper function to generate spheres (Maybe use to orbit words)
//    func sphere(radius: Float, color: UIColor) -> ModelEntity {
//        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
//        // Move sphere up by half its diameter so that it does not intersect with the mesh
//        sphere.position.y = radius
//        return sphere
//    }
}

