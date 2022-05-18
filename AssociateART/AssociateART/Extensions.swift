/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Helper functions and convenience extensions for system types.
*/

import ARKit
import RealityKit
import simd


extension simd_float4x4 {
    var position: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
    func flatOut()-> [Float]{
        
        return (0..<4).flatMap { x in (0..<4).map { y in self[x][y] } }
    }
}

extension Array where Element == Float {
    
    func expand() -> simd_float4x4 {
        var iter = simd_float4()
        var resultList = [simd_float4]()
        var result = simd_float4x4()
        var j = 0
        for i in 0..<17 {
            if ( (i % 4 == 0) && (i != 0) ) {
                j = 0
                resultList.append(iter)
                iter = simd_float4()
            }
            if(i < 16){
                iter[j] = self[i]
                j += 1
            }
        }
        result.columns.0 = resultList[0]
        result.columns.1 = resultList[1]
        result.columns.2 = resultList[2]
        result.columns.3 = resultList[3]
        return result
    }
}



extension ARMeshClassification {
    var description: String {
        switch self {
        case .ceiling: return "Ceiling"
        case .door: return "Door"
        case .floor: return "Floor"
        case .seat: return "Seat"
        case .table: return "Table"
        case .wall: return "Wall"
        case .window: return "Window"
        case .none: return "None"
        @unknown default: return "Unknown"
        }
    }
    
    var color: UIColor {
        switch self {
        case .ceiling: return .cyan
        case .door: return .brown
        case .floor: return .red
        case .seat: return .purple
        case .table: return .yellow
        case .wall: return .green
        case .window: return .blue
        case .none: return .lightGray
        @unknown default: return .gray
        }
    }
}

extension Transform {
    static func * (left: Transform, right: Transform) -> Transform {
        return Transform(matrix: simd_mul(left.matrix, right.matrix))
    }
}

extension ARMeshGeometry {
    func vertex(at index: UInt32) -> (Float, Float, Float) {
        assert(vertices.format == MTLVertexFormat.float3, "Expected three floats (twelve bytes) per vertex.")
        let vertexPointer = vertices.buffer.contents().advanced(by: vertices.offset + (vertices.stride * Int(index)))
        let vertex = vertexPointer.assumingMemoryBound(to: (Float, Float, Float).self).pointee
        return vertex
    }
    
    /// To get the mesh's classification, the sample app parses the classification's raw data and instantiates an
    /// `ARMeshClassification` object. For efficiency, ARKit stores classifications in a Metal buffer in `ARMeshGeometry`.
    func classificationOf(faceWithIndex index: Int) -> ARMeshClassification {
        guard let classification = classification else { return .none }
        assert(classification.format == MTLVertexFormat.uchar, "Expected one unsigned char (one byte) per classification")
        let classificationPointer = classification.buffer.contents().advanced(by: classification.offset + (classification.stride * index))
        let classificationValue = Int(classificationPointer.assumingMemoryBound(to: CUnsignedChar.self).pointee)
        return ARMeshClassification(rawValue: classificationValue) ?? .none
    }
    
    func vertexIndicesOf(faceWithIndex faceIndex: Int) -> [UInt32] {
        assert(faces.bytesPerIndex == MemoryLayout<UInt32>.size, "Expected one UInt32 (four bytes) per vertex index")
        let vertexCountPerFace = faces.indexCountPerPrimitive
        let vertexIndicesPointer = faces.buffer.contents()
        var vertexIndices = [UInt32]()
        vertexIndices.reserveCapacity(vertexCountPerFace)
        for vertexOffset in 0..<vertexCountPerFace {
            let vertexIndexPointer = vertexIndicesPointer.advanced(by: (faceIndex * vertexCountPerFace + vertexOffset) * MemoryLayout<UInt32>.size)
            vertexIndices.append(vertexIndexPointer.assumingMemoryBound(to: UInt32.self).pointee)
        }
        return vertexIndices
    }
    
    func verticesOf(faceWithIndex index: Int) -> [(Float, Float, Float)] {
        let vertexIndices = vertexIndicesOf(faceWithIndex: index)
        let vertices = vertexIndices.map { vertex(at: $0) }
        return vertices
    }
    
    func centerOf(faceWithIndex index: Int) -> (Float, Float, Float) {
        let vertices = verticesOf(faceWithIndex: index)
        let sum = vertices.reduce((0, 0, 0)) { ($0.0 + $1.0, $0.1 + $1.1, $0.2 + $1.2) }
        let geometricCenter = (sum.0 / 3, sum.1 / 3, sum.2 / 3)
        return geometricCenter
    }
}

extension Scene {
    // Add an anchor and remove it from the scene after the specified number of seconds.
/// - Tag: AddAnchorExtension
    func addAnchor(_ anchor: HasAnchoring, removeAfter seconds: TimeInterval) {
        guard let model = anchor.children.first as? HasPhysics else {
            return
        }
        
        // Set up model to participate in physics simulation
        if model.collision == nil {
            model.generateCollisionShapes(recursive: true)
            model.physicsBody = .init()
        }
        // ... but prevent it from being affected by simulation forces for now.
        model.physicsBody?.mode = .kinematic
        
        addAnchor(anchor)
        // Making the physics body dynamic at this time will let the model be affected by forces.
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { (timer) in
            model.physicsBody?.mode = .dynamic
        }
        Timer.scheduledTimer(withTimeInterval: seconds + 3, repeats: false) { (timer) in
            self.removeAnchor(anchor)
        }
    }
    // Remove an anchor from the scene after the specified number of seconds.
/// - Tag: RemoveAnchorExtension
    func removeAnchor(_ anchor: HasAnchoring, physics: Bool) {
        let words = RenderedText()
//        words.deleteEntity(tapEntity: )(anchor: anchor)
    }
}
//Add done button to hide the keyboard
extension UITextView {

    func addDoneButton(title: String, target: Any, selector: Selector) {

        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3 //.plain
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}




