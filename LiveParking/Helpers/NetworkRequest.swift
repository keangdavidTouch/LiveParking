//
//  Network.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation

enum HTTPMethodRequest:String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

protocol NetworkRequest: AnyObject {

    associatedtype ModelType:Codable
    func decode(_ data:Data) -> ModelType?
    func load(withCompletion completion: @escaping(ModelType?) -> ())
}

extension NetworkRequest {

    internal func loadURL(_ url:URL, httpMethod:HTTPMethodRequest, withCompletion completion:@escaping(ModelType?) -> ()) {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            if let data = data {
                completion(self?.decode(data))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
