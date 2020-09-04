//
//  ParkingAPIRequest.swift
//  LiveParking
//
//  Created by touch keang david on 9/4/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

class ParkingAPIRequest {
    
    let url = URL(string: "https://data.stad.gent/api/records/1.0/search/?dataset=bezetting-parkeergarages-real-time&q=&rows=10")!
}

extension ParkingAPIRequest: NetworkRequest {
    
    func decode(_ data: Data) -> ParkingModel? {
        do {
            return try JSONDecoder().decode(ParkingModel.self, from: data)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func load(withCompletion completion: @escaping (ParkingModel?) -> Void) {
        loadURL(url, httpMethod: .get, withCompletion: completion)
    }
}
