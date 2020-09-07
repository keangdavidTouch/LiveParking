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

class SortViewController: UIViewController, StoryboardInstantiable {

    @IBOutlet weak var tableView: UITableView!
    
    static var storyboardName: String {
        return StoryboardName.main.rawValue
    }
    
    weak var delegate:SortViewControllerDelegate?
    var selectedSortIndex = ParkingSortOrder.alphabet.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if let sortIndex = UserPreferences.sortOrder.value as? Int {
             selectedSortIndex = sortIndex
        }
    }
}

extension SortViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let previousSelectedIndexPath = IndexPath(row: selectedSortIndex, section: 0)
        tableView.cellForRow(at: previousSelectedIndexPath)?.accessoryType = .none
        
        selectedSortIndex = indexPath.row
        UserPreferences.sortOrder.save(selectedSortIndex)
        delegate?.sortViewControllerDidPressSortBy(sortOrder: ParkingSortOrder(rawValue: selectedSortIndex) ?? .alphabet)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SortViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParkingSortOrder.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.reuseIdentifier) as! SortTableViewCell
        cell.title.text = ParkingSortOrder(rawValue: indexPath.row)?.title
        
        if indexPath.row == selectedSortIndex {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
}
