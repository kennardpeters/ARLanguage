//
//  Tapped.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/27/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import RealityKit
import ARKit

class Tapped {
    var entity: Entity?
    var anchor: HasAnchoring?
    required init(ARView: ARView, tapLocation: CGPoint) {
        guard let resultEntity = ARView.entity(at: tapLocation) else { return }
        self.entity = resultEntity
        //Returns anchor associated with that entity
        guard let resultAnchor = self.entity?.anchor else { return }
        self.anchor = resultAnchor
    }
    
}
