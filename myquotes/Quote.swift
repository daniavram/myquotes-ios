//
//  Quote.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import ObjectMapper

class Quote: Mappable {
    
    private var _id: Int?
    private var _created: String?
    private var _modified: String?
    private var _title: String?
    private var _text: String?
    private var _author: Author?
    private var _category: Category?
    private var _tags: [Tag]?
    
    var id: Int? {
        return _id
    }
    var created: String? {
        return _created
    }
    var modified: String? {
        return _modified
    }
    var title: String? {
        get {
            return _title
        }
        
        set {
            self._title = newValue
        }
    }
    var text: String? {
        get {
            return _text
        }
        
        set {
            self._text = newValue
        }
    }
    var author: Author? {
        get {
            return _author
        }
        
        set {
            self._author = newValue
        }
    }
    var category: Category? {
        get {
            return _category
        }
        
        set {
            self._category = newValue
        }
    }
    var tags: [Tag]? {
        get {
            return _tags
        }
        
        set {
            self._tags = newValue
        }
    }
    
    typealias BuilderClosure = (Quote) -> ()
    
    init(builder: BuilderClosure) {
        builder(self)
    }
    
    init() {
    }
    
    required init(map: Map) {
    }
    
    private let datePrettify = TransformOf<String, String>(
        fromJSON: { (value: String?) -> String? in
            
            guard let value = value else {
                return nil
            }
            
            let dateString = Date.string(from: value)
            
            return dateString
            
        }, toJSON: { (value: String?) -> String? in
            return value
        }
    )
    
    private let quoteTextPrettify = TransformOf<String, String>(
        fromJSON: { (value: String?) -> String? in
            
            guard let value = value else {
                return nil
            }
            
            let decodedString = try? value.htmlDecode()
            
            return decodedString
        
        }, toJSON: { (value: String?) -> String? in
            return value
        }
    )
    
    func mapping(map: Map) {
        self._id <- map["id"]
        self._created <- (map["created"], datePrettify)
        self._modified <- (map["modified"], datePrettify)
        self._title <- map["title"]
        self._text <- (map["text"], quoteTextPrettify)
        self._author <- map["author"]
        self._category <- map["category"]
        self._tags <- map["tags"]
    }
    
    func has(tags searchTags: [Tag]) -> Bool {
        
        guard let tags = self.tags else {
            return false
        }
        
        let tagsSet = Set(tags)
        let tagsSubset = Set(searchTags)
        
        let isSubset = tagsSubset.isSubset(of: tagsSet)
        
        return isSubset
    }
    
}
