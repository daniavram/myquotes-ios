//
//  AddQuoteViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 21/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import TagListView

class AddQuoteViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleTextView: KMPlaceholderTextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var newTagTextField: UITextField!
    @IBOutlet weak var tagsView: TagListView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var quoteTextView: KMPlaceholderTextView!
    @IBOutlet weak var authorsTableView: UITableView!
    
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var authorsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var categoriesTableViewHeight: NSLayoutConstraint!
    
    var authorsViewController: PropertyViewController?
    var categoriesViewController: PropertyViewController?
    
    var authors: [Author]!
    var categories: [Category]!
    var tags: [Tag]!
    
    private var quote: Quote!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quote = Quote()
        
        initViewInterface()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(postQuote))
        
        API.get(Category(), completion: { categories in
            self.categories = categories
            self.categoriesViewController = PropertyViewController(
                tableView: self.categoriesTableView,
                view: self.view,
                tableViewHeight: self.categoriesTableViewHeight,
                properties: self.categories,
                textField: self.categoryTextField,
                scrollView: self.scrollView,
                quote: self.quote
            )
        })
        
        API.get(Author(), completion: { authors in
            self.authors = authors
            self.authorsViewController = PropertyViewController(
                tableView: self.authorsTableView,
                view: self.view,
                tableViewHeight: self.authorsTableViewHeight,
                properties: self.authors,
                textField: self.authorTextField,
                scrollView: self.scrollView,
                quote: self.quote
            )
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        API.get(Tag(), completion: { tags in
            self.tags = tags
            self.tagsView.addTags(from: tags)
            self.showTagsView(true)
        })
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissViewController() {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func initViewInterface() {
        
        tagsView.delegate = self
        newTagTextField.delegate = self
        
        self.navigationController?.navigationBar.tintColor = Theme.primary.color
        
        titleTextView.font = Font.type(for: .title)
        creationDateLabel.font = Font.type(for: .date)
        creationDateLabel.text = Date.now()
        newTagTextField.font = Font.type(for: .property)
        categoryTextField.font = Font.type(for: .property)
        tagsViewHeight.constant = 0
        tagsView.alpha = 0
        quoteTextView.font = Font.type(for: .quote)
        authorTextField.font = Font.type(for: .author)
    }
    
    func postQuote() {
        
        let authorId = self.quote.author?.id ?? 0
        let categoryId = self.quote.category?.id ?? 0
        
        let customQuote: [String: Any] = [
            "title": self.titleTextView.text,
            "text": self.quoteTextView.text,
            "author": "\(authorId)",
            "category": "\(categoryId)",
            "tags": self.selectedTagsIds()
        ]
        
        API.post(quote: customQuote, completion: { success in
            if success {
                self.dismissViewController()
            } else {
                self.postFailed()
            }
        })
        
    }
    
    private func showTagsView(_ show: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            if show {
                self.tagsViewHeight.constant = self.tagsView.intrinsicContentSize.height
            } else {
                self.tagsView.alpha = 0
            }
            self.view.layoutIfNeeded()
        }, completion: { success in
            
            UIView.animate(withDuration: 0.3, animations: {
                if show {
                    self.tagsView.alpha = 1.0
                } else {
                    self.tagsViewHeight.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        
        })
        
    }
    
    private func selectedTagsIds() -> [String] {
        
        var tagsIds = [String]()
        
        for iterator in self.tagsView.tagViews {
            if let id = iterator.id, iterator.isSelected {
                tagsIds.append("\(id)")
            }
        }
        
        return tagsIds
    }
    
    private func postFailed() {
        
        let alertController = UIAlertController(title: "Blimey", message: "Something's gone awry", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Shite", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func authorTextFieldDidChange(_ sender: Any) {
        self.authorsViewController?.textFieldDidChange()
    }
    
    @IBAction func categoryTextFieldDidChange(_ sender: Any) {
        self.categoriesViewController?.textFieldDidChange()
    }
    
    fileprivate func addTag(_ text: String?) {
        
        guard let text = text else {
            return
        }
        
        let alreadyExists = self.tagsView.select(tagText: text)
        
        if !alreadyExists {
            let newTag = Tag(name: text)
            
            API.post(object: newTag, completion: { tagResponse in
                guard let tagResponse = tagResponse else {
                    return
                }
                
                self.tags.append(tagResponse)
                
                self.tagsView.addTag(text.uppercased())
                self.tagsView.tagViews.last?.id = tagResponse.id
                self.tagsView.tagViews.last?.isSelected = true
                
                let desiredHeight = self.tagsView.intrinsicContentSize.height
                let actualHeight = self.tagsViewHeight.constant
                
                if  actualHeight != desiredHeight {
                    self.tagsViewHeight.constant = desiredHeight
                }
            })
        }
        
    }
    
}

extension AddQuoteViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
    }
    
}

extension TagView {
    
    private struct AssociatedKeys {
        static var id = "id"
    }
    
    var id: Int? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.id) as? Int
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.id, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension AddQuoteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addTag(textField.text)
        
        textField.text = ""
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}
