//
//  QuotesDelegate.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class QuotesDelegate: NSObject {
    
    let stateController: StateController
    let viewController: QuotesViewController
    
    init(tableView: UITableView, stateController: StateController, viewController: QuotesViewController) {
        self.stateController = stateController
        self.viewController = viewController
        super.init()
        tableView.delegate = self
    }
    
}

extension QuotesDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        stateController.selectedQuoteIndex = indexPath.row
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = self.stateController.quotes?.count,
            indexPath.row == count - 2,
            let _ = self.viewController.nextPage {
                self.viewController.updateQuotes()
        }
    }
    
}
