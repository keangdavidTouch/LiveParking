//
//  StoryboardExtension.swift
//  LiveParking
//
//  Created by touch keang david on 9/7/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit

enum StoryboardName: String {
    case main = "Main"
}

protocol StoryboardInstantiable: class {
    static var storyboardName: String { get }
}

extension StoryboardInstantiable {
    static func instantiateFromStoryboard() -> Self {
        return instantiateFromStoryboardHelper()
    }

    private static func instantiateFromStoryboardHelper<T>() -> T {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}
//
//  StoryboardInstantiable.swift
//  LiveParking
//
//  Created by touch keang david on 9/7/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation
