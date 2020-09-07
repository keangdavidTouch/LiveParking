//
//  ParkingDateHelper.swift
//  LiveParking
//
//  Created by touch keang david on 9/6/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

struct ParkingDateHelper {
    
    static let apiUpdateInterval = TimeInterval(5.25 * 60)
    
    static let formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()
    
    static func getDate(from dateString:String) -> Date {
        let dateStringWithoutTimeZone = dateString.replacingOccurrences(of: "+00:00", with: "")
        return formatter.date(from: dateStringWithoutTimeZone) ?? Date()
    }
    
    static func getNextUpdateInterval(since lastDate:Date) -> TimeInterval {
        let next = Date(timeInterval: apiUpdateInterval, since: lastDate)
        let newUpdateInterval = next.timeIntervalSinceNow
        
        if newUpdateInterval > 0 {
            return newUpdateInterval
        }
        
        return apiUpdateInterval
    }
    
    
}
