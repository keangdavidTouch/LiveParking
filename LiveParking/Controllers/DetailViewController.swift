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

class DetailViewController: UITableViewController {
 
    var parkingRecord:Record!
    weak var delegate:DetailViewControllerDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactDetailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let field = parkingRecord.fields
        nameLabel.text = field.name
        contactDetailLabel.text = field.contactinfo
        addressLabel.text = field.address
        
        parkLabel.text = parkingRecord.isParkByUser ? "PARKED!" : "PARK HERE"

        let location = parkingRecord.geometry.clLocation
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.centerToLocation(location, regionRadius: 300)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            delegate?.detailViewControllerDidPressPark()
            parkLabel.text = "PARKED!"
        }
    }
}
