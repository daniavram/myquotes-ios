//
//  Font.swift
//  my-quotes
//
//  Created by Daniel Avram on 21/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

enum FontType {
    
    case title
    case titleItalic
    case quote
    case author
    case property
    case tag
    case date
    case cellQuote
    case cellAuthor
    case cellTitle
    case login
}

struct Font {
    
    static func type(for type: FontType) -> UIFont {
        switch type {
        case .title:
            return UIFont(name: "SourceSansPro-Semibold", size: 38)!
        case .titleItalic:
            return UIFont(name: "SourceSansPro-SemiboldIt", size: 32)!
        case .quote:
            return UIFont(name: "SourceSansPro-Light", size: 26)!
        case .author:
            return UIFont(name: "SourceSansPro-Semibold", size: 20)!
        case .property:
            return UIFont(name: "SourceSansPro-Light", size: 18)!
        case .tag:
            return UIFont(name: "SourceSansPro-Regular", size: 14)!
        case .date:
            return UIFont(name: "SourceSansPro-ExtraLight", size: 16)!
        case .cellQuote:
            return UIFont(name: "SourceSansPro-Light", size: 15)!
        case.cellAuthor:
            return UIFont(name: "SourceSansPro-Regular", size: 14)!
        case.cellTitle:
            return UIFont(name: "SourceSansPro-Semibold", size: 18)!
        case .login:
            return UIFont(name: "SourceSansPro-Light", size: 22)!
        }
    }
    
}
