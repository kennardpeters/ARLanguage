//
//  colorStr.swift
//  AssociateART
//
//  Created by Kennard Peters on 4/29/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import UIKit

class colorStr {
    var pickerData: [String]
    
    required init() {
        //variable to hold colors as strings
        self.pickerData = ["Blue", "Red", "Yellow", "Purple", "Orange", "Cyan", "Green", "Gray", "Clear", "Brown", "Magenta", "Pink", "Teal", "White","Black"]
    }
    func pickColor(colorStr: String?) -> UIColor {
        guard (colorStr != nil) else {return .purple}
        switch colorStr {
        case "Blue": return .blue
        case "Red": return .red
        case "Yellow": return .yellow
        case "Purple": return .purple
        case "Cyan": return .cyan
        case "Orange": return .orange
        case "Green": return .green
        case "Gray": return .gray
        case "Clear": return .clear
        case "Brown": return .brown
        case "Magenta": return .magenta
        case "Pink": return .systemPink
        case "Teal": return .systemTeal
        case "White": return .white
        case "Black": return .black
        default: return .purple
        }
    }
}
