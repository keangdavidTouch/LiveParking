//
//  ParkingAPIRequest.swift
//  LiveParking
//
//  Created by touch keang david on 9/4/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

class ParkingAPIRequest {
    
    let url:URL
    private var urlString = "https://data.stad.gent/api/records/1.0/search/?dataset=bezetting-parkeergarages-real-time&q=&sort=lastupdate"
    
    init(rows:Int = 10) {
        urlString.append(contentsOf: "&rows=\(rows)")
        url = URL(string: urlString)!
    }
}

extension ParkingAPIRequest: NetworkRequest {
    
    func decode(_ data: Data) -> ParkingModel? {
        do {
            return try JSONDecoder().decode(ParkingModel.self, from: data)
        }
        catch {
            print("Errors while decoding Parking Records: \(error)")
            return nil
        }
    }
    
    func load(withCompletion completion: @escaping (ParkingModel?) -> Void) {
        loadURL(url, httpMethod: .get, withCompletion: completion)
    }
}
