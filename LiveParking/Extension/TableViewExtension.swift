//
//  TableViewExtension.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }   
}
