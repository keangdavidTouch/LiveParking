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
    let dateHelper = ParkingDateHelper()
    let locationService = DefaultLocationService()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        locationService.delegate = self
        fetchParkingRecord()
    }
    
    func fetchParkingRecord() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.request.load { [weak self] (parkingModel:ParkingModel?) in
                
                guard let model = parkingModel else { return }
                print("✅ [NEW RECORDS UPDATED]...............")
                self?.model = model
                
                let sortIndex = UserPreferences.sortOrder.value as? Int
                self?.model.sortRecords(by: ParkingSortOrder(rawValue: sortIndex ?? 0) ?? .alphabet)
                
                self?.locationService.startUpdateLocation()
                
                let lastUpdate = model.recentUpdateDate
                let nextUpdateInterval = ParkingDateHelper.getNextUpdateInterval(since: lastUpdate)
                print("Next Update Interval: \(nextUpdateInterval) SEC")
                self?.updateTimer()
                
                // Schedule Next RecordFetching
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + nextUpdateInterval) {
                    self?.fetchParkingRecord()
                }
                
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                }
            }
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
            
            let sortIndex = UserPreferences.sortOrder.value as? Int
            if(sortIndex == ParkingSortOrder.distance.rawValue) {
                self?.model.sortRecords(by: .distance)
            }
            self?.tableView.reloadData()
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
