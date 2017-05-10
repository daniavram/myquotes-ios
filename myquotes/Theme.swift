//
//  Theme.swift
//  my-quotes
//
//  Created by Daniel Avram on 23/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//
//  Color names used are taken from Sip (mac software)

import UIKit
import TagListView

enum Theme {
    
    case primary
    case secondary
    case warning
    
    case lightText
    case darkText
    
    case lightBackground
    case darkBackground
    
}

extension Theme {
    
    var color: UIColor {
        
        switch self {
        case .primary:
            // Mountain Meadow
            return UIColor(red:0.13, green:0.81, blue:0.51, alpha:1.00)
        case .secondary:
            // Vivid Cerise
            return UIColor(red:0.84, green:0.09, blue:0.47, alpha:1.00)
        case .warning:
            // Pink Orange
            return UIColor(red:1.00, green:0.58, blue:0.44, alpha:1.00)
        case .lightText:
            // Lily White
            return UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.00)
        case .lightBackground:
            // Geyser
            return UIColor(red:0.80, green:0.81, blue:0.81, alpha:1.00)
        case .darkText, .darkBackground:
            // Dove Gray
            return UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.00)
        }
    }
    
}

extension Theme {
    
    static func setupAppearance() {
        
        let tagsView = TagListView.appearance()
        tagsView.backgroundColor = .clear
        tagsView.cornerRadius = 2.0
        tagsView.textFont = Font.type(for: .tag)
        tagsView.tagBackgroundColor = Theme.lightBackground.color
        tagsView.textColor = .white
        tagsView.selectedTextColor = .white
        tagsView.tagSelectedBackgroundColor = Theme.primary.color
        tagsView.paddingX = 6
        tagsView.paddingY = 4
        tagsView.marginY = 5
                
        let textField = UITextField.appearance()
        textField.tintColor = Theme.primary.color
        
        let textView = UITextView.appearance()
        textView.tintColor = Theme.primary.color
        
        let searchBar = UISearchBar.appearance()
        searchBar.tintColor = Theme.primary.color
//        searchBar.barTintColor = Theme.lightBackground.color
        
        let button = UIButton.appearance()
        button.tintColor = Theme.primary.color        
    }
    
}
