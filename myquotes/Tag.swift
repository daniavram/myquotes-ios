//
//  Tag.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation

class Tag: Property {
    
    var isSelected = false
    
}

extension Tag: Equatable {
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension Tag: Hashable {
    
    var hashValue: Int {
        return self.id!
    }
    
}
