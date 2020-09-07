//
//  LocationService.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import MapKit
import CoreLocation

public protocol LocationServiceDelegate: class {
    func locationService(didUpdateLocation location: CLLocation)
}

public protocol LocationService: class {
    func startUpdateLocation()
    func stopUpdateLocation()
    func calculateRouteDistance(between from:CLLocation, _ to:CLLocation, completion: @escaping(CLLocationDistance) -> ())
}

class DefaultLocationService:NSObject, LocationService {
    
    private var locationManager:CLLocationManager!
    private let geoCoder = CLGeocoder()
    weak var delegate:LocationServiceDelegate?
    
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
    }
    
    public func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
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
        
        let age = -location.timestamp.timeIntervalSinceNow
        print("Update Location \(age)")
        if age > 10{
            return
        }
        
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 100{
            return
        }
        
        getLocationDescription(of: location) {
            print("📍New Location -> \($0)")
            self.delegate?.locationService(didUpdateLocation: location)
        }
    }
}


