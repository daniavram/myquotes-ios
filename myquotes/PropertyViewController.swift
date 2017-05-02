//
//  PropertyViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 15/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit
import ObjectMapper

enum PropertyType {
    case author
    case category
}

class PropertyViewController: NSObject {
    
    static let rowHeight: CGFloat = 44
    static let maxTableViewHeight: CGFloat = 180
    
    var tableView: UITableView!
    var tableViewHeight: NSLayoutConstraint!
    var view: UIView!
    var scrollView: UIScrollView!
    var textField: UITextField!
    var presentedProperties: [Property]?
    var properties: [Property]?
    
    var showTableView: Bool = false {
        didSet {
            self.showTableView(self.showTableView)
        }
    }
    
    private var propertyDelegate: PropertyDelegate!
    private var propertyDatasource: PropertyDatasource!
    private var propertyTextFieldDelegate: PrepertyTextFieldDelegate!
    
    private var propertyType: PropertyType!
    private var quote: Quote!

    init(tableView: UITableView, view: UIView, tableViewHeight: NSLayoutConstraint, properties: [Property], textField: UITextField, scrollView: UIScrollView, quote: Quote) {
        self.tableView = tableView
        self.tableViewHeight = tableViewHeight
        self.view = view
        self.scrollView = scrollView
        self.presentedProperties = properties
        self.properties = properties
        self.textField = textField
        
        if self.properties is [Author] {
            self.propertyType = .author
        } else if self.properties is [Category] {
            self.propertyType = .category
        }
        
        self.quote = quote
        
        super.init()
        
        self.propertyDelegate = PropertyDelegate(tableView: self.tableView, viewController: self)
        self.propertyDatasource = PropertyDatasource(tableView: self.tableView, viewController: self)
        self.propertyTextFieldDelegate = PrepertyTextFieldDelegate(textField: self.textField, viewController: self)
        
        self.tableView.dataSource = self.propertyDatasource
        self.tableView.delegate = self.propertyDelegate
        self.textField.delegate = self.propertyTextFieldDelegate
        
        self.tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        
        self.tableView.backgroundColor = .white
        self.tableView.backgroundView?.backgroundColor = .white
        
    }
    
    func addProperty() {
        
        var newProperty: Property!
        
        if propertyType == .author {
            newProperty = Author(name: textField.text!)
        }
        if propertyType == .category {
            newProperty = Category(name: textField.text!)
        }
        
        guard !alreadyExists(newProperty) else {
            selectProperty(at: (self.presentedProperties?.count)! - 1)
            return
        }
        
        self.properties?.append(newProperty)
        
        self.showTableView = false
        self.dismissKeyboard()

        API.post(object: newProperty, completion: { response in
            self.presentedProperties?.last?.id = response?.id
            self.selectProperty(at: (self.presentedProperties?.count)! - 1)
            self.tableView.reloadData()
        })
    }
    
    func deleteProperty(at index: Int) {
        
        let property = self.presentedProperties?[index]
        
        if self.textField?.text! == property?.name! {
            self.textField?.text = nil
        }
        
        var endpoint: Endpoint!
        
        if self.propertyType == .author {
            endpoint = Endpoint.authors
        } else if self.propertyType == .category {
            endpoint = Endpoint.categories
        }
        
        API.delete(endpoint, id: (property?.id!)!, completion: { success in
            if success {
                self.presentedProperties?.remove(at: index)
                
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                self.properties = self.presentedProperties
            } else {
                self.tableView.setEditing(false, animated: true)
            }
        })
        
    }
    
    func selectProperty(at index: Int) {
        
        let selectedProperty = self.presentedProperties?[index]
        
        self.textField?.text = selectedProperty?.name
        
        if propertyType == .author {
            self.quote.author = Author(id: selectedProperty?.id)
        } else if propertyType == .category {
            self.quote.category = Category(id: selectedProperty?.id)
        }
        
        self.showTableView = false
        self.dismissKeyboard()
    }
    
    private func alreadyExists(_ property: Property) -> Bool {
        
        let exists = self.properties?.contains(where: { iterator in
            if iterator.name == property.name {
                return true
            } else {
                return false
            }
        })
        
        return exists!
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func showTableView(_ show: Bool) {
        
        self.presentedProperties = self.properties
        self.tableView.reloadData()
        
        UIView.animate(withDuration: 0.4, animations: {
            if show {
                
                self.tableViewHeight.constant = PropertyViewController.maxTableViewHeight
                
                let offset = self.scrollView.contentOffset
                let textFieldY = self.textField.frame.origin.y
                let desiredY = PropertyViewController.maxTableViewHeight
                let scrollAmount = textFieldY >= desiredY ? desiredY : textFieldY - PropertyViewController.rowHeight
                
                self.scrollView.setContentOffset(CGPoint(x: offset.x, y: offset.y + scrollAmount), animated: true)
            } else {
                self.tableViewHeight.constant = 0
            }
            self.view.layoutIfNeeded()
        })
        
    }
    
    func textFieldDidChange() {
        if self.textField.isEmpty {
            self.presentedProperties = self.properties
            self.tableView.reloadData()
        } else {
            
            let text = self.textField.text?.replacingOccurrences(of: " ", with: "+")
            
            if self.propertyType == .author {
                API.get(Author(), containing: text!, completion: { authors in
                    self.presentedProperties = authors
                    self.tableView.reloadData()
                })
            }
        }
    }

}
