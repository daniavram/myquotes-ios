//
//  PropertyTextFieldController.swift
//  my-quotes
//
//  Created by Daniel Avram on 17/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class PrepertyTextFieldDelegate: NSObject {
    
    var textField: UITextField!
    let viewController: PropertyViewController!
    
    init(textField: UITextField, viewController: PropertyViewController) {
        self.textField = textField
        self.viewController = viewController
        super.init()
    }
    
}

extension PrepertyTextFieldDelegate: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewController.showTableView = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewController.showTableView = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.viewController.addProperty()
        
        return true
    }
    
}
