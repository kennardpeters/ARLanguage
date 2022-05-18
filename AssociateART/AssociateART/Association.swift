//
//  Association.swift
//  AssociateART
//
//  Created by Kennard Peters on 3/29/21.
//  Copyright © 2021 Apple. All rights reserved.
//
//Used to create an Abstract Data Type for Associations

import UIKit
import ARKit
import RealityKit

//Need to add more meta data (Change String to a list)
//public class Association {
////    var word: [String]
////    var ID: [UInt64]
////    var element: [UInt64:[String]]
//    private var words: [UInt64: Entity] = [:]
//
//    init() {
//        words = [:]
//    }
//    subscript(index: UInt64) ->  Entity{
//        get {
//            guard let rValue = words[index] else {
//                print("no Entity")
//                let boxMesh = MeshResource.generateText("Nothing")
//                return ModelEntity(mesh: boxMesh)
//            }
//            return rValue
//        }
//        set(newValue) {
//            self.words[index] = newValue
//
//        }
//    }
//}
