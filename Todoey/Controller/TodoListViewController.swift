//
//  ViewController.swift
//  Todoey
//
//  Created by Luca Grotto on 07/05/2019.
//  Copyright © 2019 Luca Grotto. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let sc = UISearchController(searchResultsController: nil)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSearchBar()
        loadItems()
    }
    
    //    MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //    MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //    MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        alert.addTextField { (alertText) in
            alertText.placeholder = "Create new item"
            textField = alertText
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //    MARK: - Model manipulation methods
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            try itemArray = context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchResultsUpdating{
  
    func initializeSearchBar() {
        if #available(iOS 11.0, *) {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.delegate = self as? UISearchControllerDelegate
            searchController.searchResultsUpdater = self
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
            definesPresentationContext = true
        }
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return sc.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        print(searchText)
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
