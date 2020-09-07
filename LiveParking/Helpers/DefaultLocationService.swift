//
//  DefaultLocationService.swift
//  LiveParking
//
//  Created by touch keang david on 9/7/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import MapKit
import CoreLocation

class DefaultLocationService:NSObject, LocationService {
    
    private let geoCoder = CLGeocoder()
    private var lastLocation:CLLocation!
    private var locationManager:CLLocationManager!
    weak var delegate:LocationServiceDelegate?
    
    var lastUpdatedLocation: CLLocation! {
        return lastLocation
    }
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = .automotiveNavigation
            locationManager.distanceFilter = 10
            locationManager.allowsBackgroundLocationUpdates = false
        }
    }
    
    public func startUpdateLocation() {
        locationManager.startUpdatingLocation()
        print("✅ START UPDATE LOCATION...")
        if let location = lastUpdatedLocation {
            self.delegate?.locationService(didUpdateLocation: location)
        }
    }
    
    public func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func calculateLineDistance(between from: CLLocation, _ to: CLLocation, completion: @escaping (CLLocationDistance) -> ()) {
        let distance = to.distance(from: from)
        completion(distance)
    }
    
    public func calculateRouteDistance(between from:CLLocation, _ to:CLLocation, completion: @escaping(CLLocationDistance) -> ()) {
        let source          = MKPlacemark(coordinate: from.coordinate)
        let destination     = MKPlacemark(coordinate: to.coordinate)
        
        let request = MKDirections.Request()
        request.source      = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate { (response, error) in
            if let response = response, let route = response.routes.first {
                completion(route.distance)
            }
        }
    }
    
    func getLocationDescription(of location:CLLocation, completion: @escaping(String) -> ()) {
        geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place.thoroughfare!) \(place.postalCode!) \(place.locality!) \(place.country!)"
                completion(description)
          }
        }
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
       
        if let last = lastLocation {
            let age = location.timestamp.timeIntervalSince(last.timestamp)
            if age < 10.0 {
                getLocationDescription(of: location) {
                    print("❌ Discard Location(🔎 age == \(age) -> \($0)")
                }
                return
            }
        }
        
        getLocationDescription(of: location) {
            print("📍New Location -> \($0)")
            self.delegate?.locationService(didUpdateLocation: location)
            self.lastLocation = location
        }
    }
}
