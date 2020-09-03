//
//  MapKitExtension.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import MapKit

extension MKMapView {
    
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
