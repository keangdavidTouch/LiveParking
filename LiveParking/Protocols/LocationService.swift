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
    var delegate: LocationServiceDelegate? { get set }
    var lastUpdatedLocation:CLLocation! { get }
    
    func startUpdateLocation()
    func stopUpdateLocation()
    func calculateLineDistance(between from:CLLocation, _ to:CLLocation, completion: @escaping(CLLocationDistance) -> ())
    func calculateRouteDistance(between from:CLLocation, _ to:CLLocation, completion: @escaping(CLLocationDistance) -> ())
}




