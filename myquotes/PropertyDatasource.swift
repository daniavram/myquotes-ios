//
//  PropertyDatasource.swift
//  my-quotes
//
//  Created by Daniel Avram on 15/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class PropertyDatasource: NSObject {
    
    let viewController: PropertyViewController
    
    init(tableView: UITableView, viewController: PropertyViewController) {
        self.viewController = viewController
        super.init()
    }
}

extension PropertyDatasource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.viewController.presentedProperties?.count ?? 0
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = self.viewController.presentedProperties?[indexPath.row].name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewController.deleteProperty(at: indexPath.row)
        }
    }
    
}
