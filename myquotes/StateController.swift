//
//  StateController.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import UIKit

class StateController {
    
    var quotes: [Quote]?
    var selectedQuoteIndex: Int?
    
    init() {
        self.quotes = [Quote]()
        self.selectedQuoteIndex = nil
    }
    
    func select(tags: [Tag], in quotes: [Quote]) {
        
        for quote in quotes {
            for quoteTag in quote.tags! {
                quoteTag.isSelected = false
                for tag in tags {
                    if tag.id == quoteTag.id {
                        quoteTag.isSelected = true
                    }
                }
            }
        }
        
        self.quotes = quotes
        
    }
    
}
