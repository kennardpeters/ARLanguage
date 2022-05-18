//
//  ImageViewController.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/27/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import UIKit


class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var pickedImage = false
    
    override func viewDidAppear(_ animated: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) && !pickedImage {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
            pickedImage = true
        }
    }
    //Need to pass image to Main storyboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMain" {
            let dvc = segue.destination as! ViewController
            dvc.newImage = imageView.image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    //PUT in Main View Controller
    //GLOBAL ******
//    var newImage: UIImage?
    //************
//    var myMaterial = SimpleMaterial()
//    guard let image = newImage else { return }
//    let remoteURL = URL(dataRepresentation: image, relativeTo: , isAbsolute: )
//    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
//    let data = try! Data(contentsOf: image)
//
//    myMaterial.baseColor try!
    
}


