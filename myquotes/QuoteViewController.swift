//
//  QuoteViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {
    
    var quote: Quote?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var quoteTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewInterface()
                
        titleLabel.text = quote?.title
        
        let author = quote?.author?.name ?? "anonymous"
        authorLabel.text = author
        
        creationDateLabel.text = quote?.created
        quoteTextLabel.text = quote?.text ?? "Quote"
    }
    
    private func initViewInterface() {
        
        self.titleLabel.font = Font.type(for: .title)
        self.authorLabel.font = Font.type(for: .author)
        self.creationDateLabel.font = Font.type(for: .date)
        self.quoteTextLabel.font = Font.type(for: .quote)
        self.authorLabel.textColor = Theme.primary.color
    }
    
}
