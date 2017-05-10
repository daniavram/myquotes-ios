//
//  FilterController.swift
//  myquotes
//
//  Created by Daniel Avram on 08/05/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class FilterController: UIViewController {
    
    var containingController: QuotesViewController?
    var properties = [Property]()
    var selectedProperties = [Property]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 5
        self.tableView.reloadData()
    }

    @IBAction func dismiss(_ sender: Any) {
        
        if self.properties is [Category] {
            self.containingController?.filterControllerWillClose(with: self.selectedProperties as! [Category])
        }
        if self.properties is [Author] {
            self.containingController?.filterControllerWillClose(with: self.selectedProperties as! [Author])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilterController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        
        let selectedProperty = properties[indexPath.row]
        
        if let index = selectedProperties.index(where: { iterator in
            if iterator.id == selectedProperty.id {
                return true
            } else {
                return false
            }
        }) {
            selectedProperties.remove(at: index)
        } else {
            selectedProperties.append(selectedProperty)
        }
        
    }
    
}

extension FilterController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.properties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let property = properties[indexPath.row]
        
        cell.textLabel?.text = property.name
        cell.textLabel?.font = Font.type(for: .property)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
}
