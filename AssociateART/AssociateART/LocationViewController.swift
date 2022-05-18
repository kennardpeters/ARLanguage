//
//  LocationViewController.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/28/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            print("location = \(locValue.latitude):\(locValue.longitude)")
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("location = \(locValue.latitude):\(locValue.longitude)")
    }
}
