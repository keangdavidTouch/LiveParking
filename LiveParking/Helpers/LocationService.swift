//
//  LocationService.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService:NSObject, CLLocationManagerDelegate {
    
    static var shared = LocationService()
    private var locationManager:CLLocationManager!
    var latestLocation:CLLocation!
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
    }
    
    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        latestLocation = locations[0]
        getLocationDescription(from: locations[0]) {
            print("📍🗺 Update Location -> \($0)")
        }
        //locationManager.stopUpdatingLocation()
    }
    
    func getLocationDescription(from location:CLLocation, completion: @escaping(String) -> ()) {
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                
                let description = "\(place.thoroughfare!) \(place.postalCode!) \(place.locality!) \(place.country!)"
                completion(description)
          }
        }
    }
}


