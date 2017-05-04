//
//  Extensions.swift
//  my-quotes
//
//  Created by Daniel Avram on 11/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import UIKit
import TagListView

extension Date {
    
    static let customDateFormat: String = "d MMMM yyyy '@' H:mm"
    
    static func string(from isoString: String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let date = dateFormatter.date(from: isoString) ?? Date()
        
        dateFormatter.dateFormat = Date.customDateFormat
        
        let newDate = dateFormatter.string(from: date)
        
        return newDate
    }
    
    static func now() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = Date.customDateFormat
        
        let now = dateFormatter.string(from: Date())
        
        return now
        
    }
    
}

extension UITableView {
    
    func displayEmptyView(withText: String) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        label.numberOfLines = 0
        label.font = Font.type(for: .titleItalic)
        label.backgroundColor = Theme.lightBackground.color
        label.textColor = Theme.darkText.color
        label.textAlignment = .center
        label.text = withText
        label.sizeToFit()
        
        self.backgroundView = label
        
    }
    
    func removeEmptyView() {
        
        self.backgroundView = nil
        
    }
    
}

extension UITextField {
    
    var isEmpty: Bool {
        if self.text == nil || self.text == "" {
            return true
        } else {
            return false
        }
    }
    
}

extension TagListView {
    
    func addTags(from: [Tag]) {
        
        for tag in from {
            if let name = tag.name {
                self.addTag(name.uppercased())
                self.tagViews.last?.id = tag.id
                self.tagViews.last?.isSelected = tag.isSelected
            }
        }
        
    }
    
    func select(tagText: String) -> Bool {
        
        for tagIterator in self.tagViews {
            if tagIterator.titleLabel?.text?.lowercased() == tagText.lowercased() {
                tagIterator.isSelected = true
                return true
            }
        }
        
        return false
    }
    
}

extension Array where Element: Tag {
    
    func index(of tag: Tag) -> Int? {
        for (index, element) in self.enumerated() {
            if tag.id == element.id {
                return index
            }
        }
        return nil
    }
    
    func stringify() -> [String] {
        var tagsIds = [String]()
        
        for iterator in self {
            if let id = iterator.id {
                tagsIds.append("\(id)")
            }
        }
        
        return tagsIds
    }
    
}

extension UILabel {
    
    var htmlText: String {
        get {
            return self.attributedText?.string ?? ""
        }
        
        set {
            
            let font = Font.type(for: .cellQuote)
            
            var string = String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", font.fontName, self.font.pointSize)
            string += newValue
            
            guard let unicodedData = string.data(using: .unicode) else {
                self.attributedText = NSAttributedString(string: "")
                return
            }
            
            let options: [String: Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.unicode.rawValue
            ]
            
            let attributed = try? NSAttributedString(data: unicodedData, options: options, documentAttributes: nil)
            
            if let attributed = attributed {
                self.attributedText = attributed
            } else {
                self.attributedText = NSAttributedString(string: "")
            }
            
        }
    }
    
}
