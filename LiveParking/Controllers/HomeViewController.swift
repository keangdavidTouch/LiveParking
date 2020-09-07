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

class HomeViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet weak var tableView: UITableView!
    
    static var storyboardName: String {
        return StoryboardName.main.rawValue
    }
    
    let dateHelper = ParkingDateHelper()
    var request = ParkingAPIRequest()
    var locationService:LocationService!
    var model:ParkingModel! {
        didSet {
            model.fetchRecentUpdateDate()
            if let sortIndex = UserPreferences.sortOrder.value as? Int {
                model.sortRecords(by: ParkingSortOrder(rawValue: sortIndex) ?? .alphabet)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        locationService.delegate = self
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchParkingRecord()
        }
    }
    
    func fetchParkingRecord() {
        self.request.load { [weak self] (parkingModel:ParkingModel?) in
            guard let model = parkingModel else { return }
            self?.model = model
            
            //Start requesting location
            self?.locationService.startUpdateLocation()
            
            //Reload TableView on main thread
            DispatchQueue.main.async {
                self!.tableView.reloadData()
            }
            
            //Schedule New Records Request
            let lastUpdate = model.recentUpdateDate
            let nextUpdateInterval = ParkingDateHelper.getNextUpdateInterval(since: lastUpdate)
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + nextUpdateInterval) {
                self?.fetchParkingRecord()
            }
            
            //TESTING
            self?.updateTimer()
        }
    }
    
    @IBAction func handleSortButton(_ sender: Any) {
        let vc = SortViewController.instantiateFromStoryboard()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let nextUpdateInterval = ParkingDateHelper.getNextUpdateInterval(since: self.model.recentUpdateDate)
            self.title = "\(Int(nextUpdateInterval)) Sec"
            self.updateTimer()
        }
    }
}

extension HomeViewController: LocationServiceDelegate {
    
    func locationService(didUpdateLocation location: CLLocation) {
        model.calculateParkingDistance(from: location, locationService: locationService, completion: { [weak self] in
            
            if let sortIndex = UserPreferences.sortOrder.value as? Int,
                sortIndex == ParkingSortOrder.distance.rawValue {
                self?.model.sortRecords(by: .distance)
                self?.tableView.reloadData()
            }
        })
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

// MARK: - TableView Delegate/Datasource

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController.instantiateFromStoryboard()
        vc.delegate = self
        vc.model = model.records[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
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
