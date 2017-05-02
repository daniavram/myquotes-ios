//
//  Authentication.swift
//  my-quotes
//
//  Created by Daniel Avram on 11/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

class Authentication: Mappable {
    
    private var _email: String?
    private var _password: String?
    private var _token: String?
    
    var email: String? {
        return self._email
    }
    
    var password: String? {
        get {
            return self._password
        }
    }
    
    var token: String? {
        get {
            return self._token
        }
    }
    
    init(token: String? = nil, email: String? = nil, password: String? = nil) {
        self._token = token
        self._email = email
        self._password = password
    }
    
    required init(map: Map) {
    }
    
    func mapping(map: Map) {
        self._token <- map["token"]
        self._email <- map["email"]
        self._password <- map["password"]
    }
    
}
