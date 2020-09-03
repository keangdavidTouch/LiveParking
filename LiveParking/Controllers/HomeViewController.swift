//
//  ViewController.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    var parkingModel:ParkingModel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.global(qos: .default).async {
            self.requestJSONFromAPI()
        }
    }
    
    @IBAction func handleSortButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ViewSort", sender: self)
    }
    
    private func requestJSONFromAPI() {
        var request = URLRequest(url: URL(string: "https://data.stad.gent/api/records/1.0/search/?dataset=bezetting-parkeergarages-real-time&q=&rows=10")!)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request, completionHandler: { data, response,  error -> Void in
            
            if let data = data {
                self.parseJSONFromData(data)
            }
            
        }).resume()
    }
    
    private func parseJSONFromData(_ data:Data) {
     
        do {
            parkingModel = try JSONDecoder().decode(ParkingModel.self, from: data)
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
            
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailVC = segue.destination as? DetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                detailVC.delegate = self
                detailVC.parkingRecord = parkingModel.records[indexPath.row]
            }
        }
    }
    
    private func calculateDistance() {
        
        guard let currentLocation = LocationService.shared.latestLocation else { return }
        
        for i in parkingModel.records.indices {
            parkingModel.records[i].distanceFromUser = currentLocation.distance(from: parkingModel.records[i].geometry.clLocation) / 1000
        }
    }
    
}

extension HomeViewController: DetailViewControllerDelegate {
    func detailViewControllerDidPressPark() {
        if let indexPath = tableView.indexPathForSelectedRow {
            for i in parkingModel.records.indices {
                parkingModel.records[i].isParkByUser = false
            }
            parkingModel.records[indexPath.row].isParkByUser = true
            self.tableView.reloadData()
        }
    }
}

extension HomeViewController: SortViewControllerDelegate {
    func sortViewControllerDidPressSortBy(sortOrder: ParkingSortOrder) {
        
        switch sortOrder {
            case .alphabet:
                self.parkingModel.records.sort {
                    $0.fields.name.lowercased() < $1.fields.name.lowercased()
                }
                break
            case .capacity:
                self.parkingModel.records.sort {
                    $0.fields.availablecapacity > $1.fields.availablecapacity
                }
                break
            case .distance:
                self.calculateDistance()
                self.parkingModel.records.sort {
                    $0.distanceFromUser < $1.distanceFromUser
                }
                break
        }
        
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
        
        if let model = parkingModel {
            return model.records.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "ParkingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ParkingTableViewCell
        
        if let model = parkingModel {
            let field = model.records[indexPath.row].fields
            cell.nameLabel.text = field.name
            cell.amountLabel.text = "\(field.availablecapacity) Available   (\(Int(model.records[indexPath.row].distanceFromUser)) km)"
            cell.parkLabel.isHidden = !model.records[indexPath.row].isParkByUser
        }
        
        return cell
    }
}
