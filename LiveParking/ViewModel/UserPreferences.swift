//
//  UserPreferences.swift
//  LiveParking
//
//  Created by touch keang david on 9/4/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

enum UserPreferences: String {
    
    case parkingID
    case sortOrder
    
    func save<T>(_ value:T) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    
    var value:Any? {
        return UserDefaults.standard.value(forKey: self.rawValue)
    }
}
