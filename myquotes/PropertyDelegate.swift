//
//  PropertyDelegate.swift
//  my-quotes
//
//  Created by Daniel Avram on 15/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class PropertyDelegate: NSObject {
    
    let viewController: PropertyViewController
    
    init(tableView: UITableView, viewController: PropertyViewController) {
        self.viewController = viewController
        super.init()
    }
    
}

extension PropertyDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PropertyViewController.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.viewController.selectProperty(at: indexPath.row)
        
    }
    
}

