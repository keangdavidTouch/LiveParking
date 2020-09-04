//
//  ViewController.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class HomeViewController: UIViewController {
    
    var model:ParkingModel!
    let request = ParkingAPIRequest()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchRealTimeParkingRecord()
    }
    
    func fetchRealTimeParkingRecord() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.request.load { [weak self] (parkingModel:ParkingModel?) in
                guard let model = parkingModel else { return }
                self?.model = model
                if let sortIndex = UserPreferences.sortOrder.value as? Int {
                    self?.model.sortRecords(by: ParkingSortOrder(rawValue: sortIndex) ?? .alphabet)
                }
                self?.calculateDistance()
                OperationQueue.main.addOperation {
                    self!.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func handleSortButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ViewSort", sender: self)
    }
    
    private func calculateDistance() {
        
        guard let from = LocationService.shared.latestLocation else { return }
        
        for i in model.records.indices {
            
            let to = model.records[i].geometry.location
            
            LocationService.shared.calculateTripDistance(from, to) { (distance) in
                self.model.records[i].userDistance = distance / 1000.0
                print("\(distance / 1000.0) KM")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailVC = segue.destination as? DetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.delegate = self
                detailVC.model = model.records[indexPath.row]
            }
        }
        else if let sortVC = segue.destination as? SortViewController {
            sortVC.delegate = self
        }
    }
}

extension HomeViewController: DetailViewControllerDelegate {
    
    func detailViewControllerDidPressPark() {
        self.tableView.reloadData()
    }
}

extension HomeViewController: SortViewControllerDelegate {
    
    func sortViewControllerDidPressSortBy(sortOrder: ParkingSortOrder) {
        self.model.sortRecords(by: sortOrder)
        self.tableView.reloadData()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ViewDetail", sender: self)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let model = model else {
            return 0
        }
        return model.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParkingTableViewCell.reuseIdentifier) as! ParkingTableViewCell
        
        if let model = model {
            let viewModel = ParkingViewModel(model: model.records[indexPath.row])
            cell.nameLabel.text = viewModel.name
            cell.amountLabel.text = viewModel.capacityDescription
            cell.amountLabel.textColor = viewModel.capacityColor
            cell.parkLabel.isHidden = viewModel.isParkingHidden
        }
        
        return cell
    }
}
