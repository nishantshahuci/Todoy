//
//  ViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: SwipeTableViewController {
    
    // Search bar outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Initialize Realm
    let realm = try! Realm()
    
    // Selected list
    var selectedList: List? {
        didSet {
            loadItems()
        }
    }
    
    // Array of items for a list
    private var items: Results<Item>?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.customizeView(withSearchBar: searchBar)
        
        if let name = selectedList?.name {
            title = name
        }
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a new cell at the row
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        
        return cell
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating item: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
        
        tableView.reloadData()
    }
    
    // MARK: - CRUD operations
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // handle user pressing add button
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        // text field
        var textField = UITextField();
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        // action to add new item
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            // handle user pressing "Add" button on alert
            
            // handle case where the text is nil
            guard let text = textField.text else {
                return
            }
            
            // handle case where category is nil
            guard let category = self.selectedList else {
                return
            }
            
            if !text.isEmpty {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = text
                        category.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items: \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(addAction)
        
        // action to cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        // retrieve items from Realm
        
        items = selectedList?.items.filter("TRUEPREDICATE")
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        // delete item when swiped
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item: \(error)")
            }
        }
        
    }
    
}

// MARK: - SearchBar methods

extension ItemViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // handle user search

        if searchBar.text?.count == 0 {
            
            // reset view
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            
            // filter lists
            guard let searchText = searchBar.text else {
                return
            }

            items = selectedList?.items.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData()
            
        }
    }

}
