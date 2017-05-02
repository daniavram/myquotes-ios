//
//  QuotesViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 10/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class QuotesViewController: UITableViewController {
    
    var stateController: StateController?
    var quotesDatasource: QuotesDatasource?
    var quotesDelegate: QuotesDelegate?
    var searchController: UISearchController!
    
    var nextPage: Int? = nil
    
    fileprivate var initialQuotesResponse: QuotesResponse!
    private var top: CGPoint!
    private var selectedTags: [Tag]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "myQuotes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
        self.navigationController?.navigationBar.tintColor = Theme.primary.color
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .done, target: self, action: #selector(logOut))
        
        if let stateController = stateController {
            quotesDelegate = QuotesDelegate(tableView: self.tableView, stateController: stateController, viewController: self)
            quotesDatasource = QuotesDatasource(tableView: self.tableView, stateController: stateController, viewController: self)
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = QuoteCell.height
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.delegate = self
        
        let searchBarHeight = self.searchController.searchBar.frame.size.height
        top = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + searchBarHeight)
        
        self.refreshTable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.hideSearchBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuoteView",
            let controller = segue.destination as? QuoteViewController {
            
            if let selectedIndex = stateController?.selectedQuoteIndex,
                let quote = stateController?.quotes?[selectedIndex] {
                    controller.quote = quote
            }
            
        }
    }
 
    func addQuote() {
        stateController?.selectedQuoteIndex = nil
        performSegue(withIdentifier: "toAddQuote", sender: nil)
    }
    
    func logOut() {
        
        Keychain.delete()
        
        self.dismiss(animated: true, completion: {
            self.stateController = nil
        })
    }
    
    func refreshTable() {
        
        self.selectedTags = [Tag]()
        
        API.getQuotes(completion: { quotesResponse in
            guard let quotes = quotesResponse.quotes else {
                return
            }
            
            if let nextPage = quotesResponse.pages?.next {
                self.nextPage = nextPage
            } else {
                self.nextPage = nil
            }
            
            self.stateController?.quotes = quotes
            self.initialQuotesResponse = quotesResponse
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        })
        
    }
    
    private func hideSearchBar() {
        
        let currentOffset = self.tableView.contentOffset
        
        if currentOffset.y >= 0 && currentOffset.y < top.y {
            tableView.setContentOffset(top, animated: false)
        }
    }
    
    func updateQuotes() {
        API.getQuotes(page: self.nextPage!, containing: self.searchController.searchBar.text, completion: { quotesResponse in
            guard let quotes = quotesResponse.quotes,
                var stateControllerQuotes = self.stateController?.quotes else {
                    return
            }
            
            if let nextPage = quotesResponse.pages?.next {
                self.nextPage = nextPage
            } else {
                self.nextPage = nil
            }
            
            stateControllerQuotes = stateControllerQuotes + quotes
            self.stateController?.quotes = stateControllerQuotes
            self.tableView.reloadData()
        })
    }
    
    func tagPressed(_ tag: Tag) {
        
        if let index = self.selectedTags.index(of: tag) {
            self.selectedTags.remove(at: index)
        } else {
            self.selectedTags.append(tag)
        }
        
        API.getQuotes(tags: self.selectedTags.stringify(), completion: { quotesResponse in
            
            guard let quotes = quotesResponse.quotes else {
                return
            }
            
            self.stateController?.select(tags: self.selectedTags, in: quotes)
            self.tableView.reloadData()
        })
    }
    
}

extension QuotesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        API.getQuotes(containing: searchBar.text, completion: { quotesResponse in
            self.stateController?.quotes = quotesResponse.quotes
            
            if let nextPage = quotesResponse.pages?.next {
                self.nextPage = nextPage
            } else {
                self.nextPage = nil
            }
            
            self.tableView.reloadData()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.stateController?.quotes = self.initialQuotesResponse.quotes
        self.nextPage = self.initialQuotesResponse.pages?.next
        self.tableView.reloadData()
    }
    
}
