//
//  QuotesResponse.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

class QuotesResponse: Mappable {
    
    var pages: Pages?
    var quotes: [Quote]?
    var count: Int?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        pages <- map["pages"]
        quotes <- map["results"]
        count <- map["count"]
    }
    
}

class Pages: Mappable {
    
    var previous: Int?
    var next: Int?
    
    init(previous: Int? = nil, next: Int? = nil) {
        self.previous = previous
        self.next = next
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        previous <- map["previous"]
        next <- map["next"]
    }
}
