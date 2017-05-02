//
//  Author.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

class Author: Property {
    
    private var _quotesNumber: Int? = nil
    
    var quotesNumber: Int? {
        return _quotesNumber
    }
    
    override init(id: Int? = nil, name: String? = nil) {
        super.init()
        self.name = name
        self.id = id
    }
    
    required init(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self._quotesNumber <- map["quotes"]
    }
    
}
