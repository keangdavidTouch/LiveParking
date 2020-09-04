//
//  ParkingSortOrder.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

enum ParkingSortOrder:Int, CaseIterable {
    
    case alphabet = 0
    case distance
    case capacity
    
    var title:String? {
        
        switch self {
        case .alphabet: return "Alphabetically"
        case .distance: return "Closest Distance"
        case .capacity: return "Available Capacity"
        }
    }
}
