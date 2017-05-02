//
//  QuotesDatasource.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class QuotesDatasource: NSObject {
    
    let tableView: UITableView!
    let stateController: StateController
    let viewController: QuotesViewController
    
    init(tableView: UITableView, stateController: StateController, viewController: QuotesViewController) {
        self.tableView = tableView
        self.stateController = stateController
        self.viewController = viewController
        super.init()
        tableView.dataSource = self
    }
}

extension QuotesDatasource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuoteCell.identifier, for: indexPath) as! QuoteCell
        
        cell.containingController = self.viewController

        let quote = stateController.quotes?[indexPath.row]
        
        cell.title = quote?.title ?? "no title"
        cell.quoteText = quote?.text ?? "no text"
        cell.author = quote?.author?.name ?? "anonymous"
        cell.tags = quote?.tags
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = stateController.quotes?.count ?? 0
        
        return numberOfRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let quotesNumber = stateController.quotes?.count, quotesNumber > 0 {
            
            self.tableView.removeEmptyView()
            self.tableView.separatorStyle = .singleLine
            return 1
            
        } else {
            
            self.tableView.displayEmptyView(withText: "No Quotes to display.\nPull to refresh or\nAdd a new Quote")
            self.tableView.separatorStyle = .none
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let index = indexPath.row
            let quote = self.stateController.quotes?[index]
            
            API.delete(.quotes, id: (quote?.id)!, completion: { success in
                if success {
                    self.stateController.quotes?.remove(at: index)
                    
                    if (self.stateController.quotes?.count)! > 0 {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        self.tableView.deleteSections([indexPath.section], with: .fade)
                    }
                    
                } else {
                    self.tableView.setEditing(false, animated: true)
                }
            })
            
        }
    }
    
}
