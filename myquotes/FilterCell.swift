//
//  FilterCell.swift
//  myquotes
//
//  Created by Daniel Avram on 05/05/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    
    static let identifier = "FilterCell"
    static let height: CGFloat = 30.0
    
    var authors: String {
        get {
            return self.authors
        }
        set {
            self.authorsButton.setTitle(newValue, for: .normal)
        }
    }
    
    var categories: String {
        get {
            return self.categories
        }
        set {
            self.categoriesButton.setTitle(newValue, for: .normal)
        }
    }
    
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var authorsButton: UIButton!
    
    var containingController: QuotesViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.categoriesButton.titleLabel?.font = Font.type(for: .property)
        self.categoriesButton.setTitle("categories", for: .normal)
        
        self.authorsButton.titleLabel?.font = Font.type(for: .property)
        self.authorsButton.setTitle("authors", for: .normal)
        
    }
    
    @IBAction func categoriesButtonTap(_ sender: Any) {
        guard let containingController = self.containingController else {
            return
        }
        containingController.categoriesButtonTap()
    }
    
    @IBAction func authorsButtonTap(_ sender: Any) {
        guard let containingController = self.containingController else {
            return
        }
        containingController.authorsButtonTap()
    }
    

}
