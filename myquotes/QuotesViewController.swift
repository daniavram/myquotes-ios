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
    fileprivate var initialQuotes = [Quote]()
    fileprivate var filteredQuotes = [Quote]()
    private var top: CGPoint!
    private var selectedTags = [Tag]()
    
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
        searchController.searchResultsUpdater = self
        
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
            
            self.initialQuotesResponse = quotesResponse
            self.initialQuotes = quotesResponse.quotes ?? [Quote]()
            self.filteredQuotes = quotes
            self.stateController?.quotes = quotes
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
    
    func tagPressed(_ tag: Tag) {
        
        let quotesForFiltering: [Quote]!
        
        if let index = self.selectedTags.index(of: tag) {
            quotesForFiltering = self.initialQuotes
            self.selectedTags.remove(at: index)
        } else {
            quotesForFiltering = self.filteredQuotes
            self.selectedTags.append(tag)
        }
        
        var filteredQuotes = [Quote]()
        
        for quote in quotesForFiltering {
            
            if quote.has(tags: selectedTags) {
                filteredQuotes.append(quote)
            }
            
        }

        let quotes = filteredQuotes.isEmpty ? self.initialQuotes : filteredQuotes
        
        self.stateController?.select(tags: self.selectedTags, in: quotes)
        self.filteredQuotes = quotes
        self.tableView.reloadData()
    }
    
}

extension QuotesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = self.searchController.searchBar.text?.lowercased(),
            text != "" else {
                self.stateController?.quotes = self.filteredQuotes
                self.tableView.reloadData()
                return
        }
        
        let foundQuotes = self.filteredQuotes.filter({ quote in
            let foundInTitle = quote.title?.lowercased().contains(text)
            let foundInBody = quote.text?.lowercased().contains(text)
            
            return foundInTitle! || foundInBody!
        })
        
        self.stateController?.quotes = foundQuotes
        self.tableView.reloadData()
    }
    
}
