//
//  ParkingViewMdel.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit

struct ParkingViewModel {
    private let model: Record

    init(model: Record) {
        self.model = model
    }
    
    var name: String {
        return model.fields.name
    }
    
    var capacityDescription: String {
        return "\(model.fields.availableCapacity) Available (\(Int(model.userDistance)) km)"
    }
    
    var capacityColor: UIColor {
        let availablePercentage = CGFloat(model.fields.availableCapacity) / CGFloat(model.fields.totalcapacity)
        let greenValue = availablePercentage >= 0.5 ? 1 : availablePercentage
        return UIColor(red: 1 - greenValue, green: greenValue, blue: 0, alpha: 1)
    }
    
    var isParkingHidden:Bool {
        if let parkingID = UserPreferences.parkingID.value as? String {
            return parkingID != model.fields.id
        }
        return true
    }
}
