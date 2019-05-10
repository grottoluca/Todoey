//
//  ViewController.swift
//  Todoey
//
//  Created by Luca Grotto on 07/05/2019.
//  Copyright © 2019 Luca Grotto. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    let searchController = UISearchController(searchResultsController: nil)
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSearchBar()
    }
    
    //    MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    
    //    MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error during saving done status \(error)")
            }
        }

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //    MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                    }
                } catch {
                    print("Error saving item: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertText) in
            alertText.placeholder = "Create new item"
            textField = alertText
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //    MARK: - Model manipulation methods
    
    func loadItems() {
        items = realm.objects(Item.self)
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchResultsUpdating{
    
    func initializeSearchBar() {
        if #available(iOS 11.0, *) {
            searchController.delegate = self as? UISearchControllerDelegate
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            let scb = searchController.searchBar
            scb.tintColor = UIColor.white
            scb.barTintColor = UIColor.white
            if let textfield = scb.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.blue
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = UIColor.white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true;
                }
            }
            
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
            navigationItem.title = selectedCategory?.name
            definesPresentationContext = true
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if !searchBarIsEmpty(){
            items = items?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        } else {
            loadItems()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
