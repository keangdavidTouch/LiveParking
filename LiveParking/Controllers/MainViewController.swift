//
//  ViewController.swift
//  LiveParking
//
//  Created by touch keang david on 9/2/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var parkingModel:ParkingModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        requestJSONFromAPI()
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

}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
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
            cell.name.text = field.name
            cell.amount.text = "\(field.availablecapacity)"
        }
        
        return cell
    }
    
    
}
