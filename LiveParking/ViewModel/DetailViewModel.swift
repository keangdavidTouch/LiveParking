//
//  DetailViewModel.swift
//  LiveParking
//
//  Created by touch keang david on 9/4/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit
import MapKit

struct DetailViewModel {
    private let model: Record
    private var fields:Fields

    init(model: Record) {
        self.model = model
        self.fields = model.fields
    }
    
    var name: String {
        return fields.name
    }
    
    var contactInfo: String {
        return fields.contactinfo
    }
    
    var address: String {
        return fields.address
    }
    
    var mapLocation: CLLocation {
        return model.geometry.location
    }
    
    var mapAnnotation: MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapLocation.coordinate
        return annotation
    }
    
    var mapRegionRadius: Double {
        return 300
    }
    
    var parkByUser: Bool {
        if let parkingID = UserPreferences.parkingID.value as? String {
            return parkingID == fields.id
        }
        return false
    }
    
    var parkButtonView:((String, UIColor) -> Void)?
    
    func updateParkingState() {
        if(parkByUser) {
            parkButtonView?("Leave", UIColor.systemRed)
        }
        else {
            parkButtonView?("Park Here", UIColor.systemBlue)
        }
    }
    
}
