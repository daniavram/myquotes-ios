//
//  ViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        API.get(url: Endpoint.quotes.url(), completion: { (quotesResponse: QuotesResponse?, error: Error?) -> Void in
//            
//            guard let quotes = quotesResponse?.quotes else {
//                return
//            }
//            
//            Logger.logMappable(objects: quotes)
//        })
        
        API.get(url: Endpoint.quotes.url(id: 54), completion: {(quote: Quote?, error: Error?) -> Void in
        
            guard let quote = quote else {
                return
            }

            Logger.logMappable(object: quote)
        })
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

