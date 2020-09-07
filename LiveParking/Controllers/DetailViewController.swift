//
//  DetailViewController.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol DetailViewControllerDelegate: class {
    func detailViewControllerDidPressPark()
}

class DetailViewController: UITableViewController, StoryboardInstantiable {
    
    static var storyboardName: String {
        return StoryboardName.main.rawValue
    }
    
    var model:Record!
    private var viewModel:DetailViewModel!
    weak var delegate:DetailViewControllerDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactDetailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = DetailViewModel(model: model)
        viewModel.parkButtonView = { [weak self] (text, color) in
            self?.parkLabel.text = text
            self?.parkLabel.textColor = color
        }
        viewModel.updateParkingState()
        
        nameLabel.text = viewModel.name
        contactDetailLabel.text = viewModel.contactInfo
        addressLabel.text = viewModel.address
        mapView.addAnnotation(viewModel.mapAnnotation)
        mapView.centerToLocation(viewModel.mapLocation, regionRadius: viewModel.mapRegionRadius)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            UserPreferences.parkingID.save(!viewModel.parkByUser ? model.fields.id : "")
            viewModel.updateParkingState()
            delegate?.detailViewControllerDidPressPark()
        }
    }
}
