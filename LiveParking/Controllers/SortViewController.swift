//
//  SortViewController.swift
//  LiveParking
//
//  Created by touch keang david on 9/3/20.
//  Copyright © 2020 Keang David. All rights reserved.
//

import Foundation
import UIKit

protocol SortViewControllerDelegate: class {
    func sortViewControllerDidPressSortBy(sortOrder: ParkingSortOrder)
}

class SortViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate:SortViewControllerDelegate?
    var selectedSortOrder = ParkingSortOrder.alphabet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SortViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let previousSelectedIndexPath = IndexPath(row: selectedSortOrder.rawValue, section: 0)
        tableView.cellForRow(at: previousSelectedIndexPath)?.accessoryType = .none
        
        selectedSortOrder = ParkingSortOrder(rawValue: indexPath.row) ?? ParkingSortOrder.alphabet
        delegate?.sortViewControllerDidPressSortBy(sortOrder: selectedSortOrder)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SortViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParkingSortOrder.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let identifier = "SortTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! SortTableViewCell
        cell.title.text = ParkingSortOrder(rawValue: indexPath.row)?.title
        
        if indexPath.row == selectedSortOrder.rawValue {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
}
