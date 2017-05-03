//
//  QuoteCell.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit
import TagListView

class QuoteCell: UITableViewCell {
    
    static let identifier = "QuoteCell"
    static let height: CGFloat = 120.0
    
    @IBOutlet weak var quoteTitleLabel: UILabel!
    @IBOutlet weak var quoteTextLabel: UILabel!
    @IBOutlet weak var quoteAuthorLabel: UILabel!
    @IBOutlet weak var tagsView: TagListView!
    
    var containingController: QuotesViewController?
    
    var quoteText: String? {
        didSet {
            self.quoteTextLabel.htmlText = quoteText ?? ""
        }
    }
    
    var author: String? {
        didSet {
            self.quoteAuthorLabel.text = author
        }
    }
    
    var title: String? {
        didSet {
            self.quoteTitleLabel.text = title
        }
    }
    
    var tags: [Tag]? {
        didSet {
            self.tagsView.removeAllTags()
            if let tags = tags {
                self.tagsView.addTags(from: tags)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.quoteTextLabel.font = Font.type(for: .cellQuote)
        self.quoteAuthorLabel.font = Font.type(for: .cellAuthor)
//        self.quoteTextLabel.numberOfLines = 6
        self.quoteAuthorLabel.textColor = Theme.primary.color
        self.quoteTitleLabel.font = Font.type(for: .cellTitle)
        
        tagsView.delegate = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension QuoteCell: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        guard let containingController = containingController,
            let id = tagView.id else {
                return
        }
        
        let tag = Tag(id: id, name: title)
        containingController.tagPressed(tag)
    }
    
}
