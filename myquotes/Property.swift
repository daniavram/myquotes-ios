//
//  Property.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

class Property: Mappable {
    
    private var _id: Int?
    private var _name: String?
    
    var id: Int? {
        get {
            return self._id
        }
        
        set {
            self._id = newValue
        }
    }
    
    var name: String? {
        get {
            return self._name
        }
        
        set {
            self._name = newValue
        }
    }
    
    init(id: Int? = nil, name: String? = nil) {
        self._id = id
        self._name = name
    }
    
    required init(map: Map) {
    }
    
    func mapping(map: Map) {
        self._id <- map["id"]
        self._name <- map["name"]
    }
    
}
