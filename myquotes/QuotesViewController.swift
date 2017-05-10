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
    private var selectedCategories = [Category]() {
        didSet {
            let filterCell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! FilterCell
            filterCell.categories = selectedCategories.stringify() ?? "categories"
        }
    }
    private var selectedAuthors = [Author]() {
        didSet {
            let filterCell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! FilterCell
            filterCell.authors = selectedAuthors.stringify() ?? "authors"
        }
    }
    
    fileprivate var categories: [Category]!
    fileprivate var authors: [Author]!
    
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
        
        API.get(Author(), completion: { authors in
            self.authors = authors
        })
        
        API.get(Category(), completion: { categories in
            self.categories = categories
        })
        
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
                let quote = stateController?.quotes?[selectedIndex - 1] {
                    controller.quote = quote
            }
            
        } else if segue.identifier == "toFilter",
            let controller = segue.destination as? FilterController {
                controller.containingController = self
                if sender is Category {
                    controller.properties = self.categories
                }
                if sender is Author {
                    controller.properties = self.authors
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
        self.selectedCategories = [Category]()
        self.selectedAuthors = [Author]()
        
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
        
        if let index = self.selectedTags.index(of: tag) {
            self.selectedTags.remove(at: index)
        } else {
            self.selectedTags.append(tag)
        }
        
        let filteredQuotes = self.initialQuotes.filter(by: self.selectedCategories, authors: self.selectedAuthors, tags: self.selectedTags)

        self.stateController?.select(tags: self.selectedTags, in: filteredQuotes)
        self.filteredQuotes = filteredQuotes
        self.tableView.reloadData()
    }
    
    func categoriesButtonTap() {
        self.performSegue(withIdentifier: "toFilter", sender: Category())
    }
    
    func authorsButtonTap() {
        self.performSegue(withIdentifier: "toFilter", sender: Author())
    }
    
    func filterControllerWillClose<T: Property>(with properties: [T]) {
        
        if T.self == Category.self {
            self.selectedCategories = properties as! [Category]
        }
        if T.self == Author.self {
            self.selectedAuthors = properties as! [Author]
        }
        
        let filtered = self.initialQuotes.filter(by: self.selectedCategories, authors: self.selectedAuthors, tags: self.selectedTags)
        
        stateController?.quotes = filtered
        self.filteredQuotes = filtered
        tableView.reloadData()
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
