//
//  CategoryViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import RealmSwift

class ListViewController: SwipeTableViewController {
    
    // Search bar outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Initialize Realm
    let realm = try! Realm()
    
    // Array of lists
    var lists: Results<List>?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.customizeView(withSearchBar: searchBar)
    }

    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of rows
        
        return lists?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return new cell
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let listName = lists?[indexPath.row].name {
            cell.textLabel?.text = listName
        }
        
        return cell
        
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true);
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! ItemViewController
        
        guard let indexPath = tableView.indexPathForSelectedRow else {
            fatalError("Error getting index path for selected row")
        }
        
        destination.selectedList = lists?[indexPath.row]
    }

    // MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // handle user pressing add button
        
        let alert = UIAlertController(title: "Create new list", message: "", preferredStyle: .alert)
        
        // text field
        var textField = UITextField();
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new list"
            textField = alertTextField
        }
        
        // action to create new list
        let addAction = UIAlertAction(title: "Create", style: .default) { (action) in
            // handle user pressing "Create" button on alert
            
            // handle case where the text is null
            guard let text = textField.text else {
                return
            }
            
            if !text.isEmpty {
                let newList = List()
                newList.name = text
                do {
                    try self.realm.write {
                        self.realm.add(newList)
                    }
                } catch {
                    print("Error saving context: \(error)")
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
    
    // MARK: - Read items
    
    func loadItems() {
        // retrieve lists from Realm

        lists = realm.objects(List.self)

        tableView.reloadData()
    }
    
    // MARK: - Delete item
    
    override func updateModel(at indexPath: IndexPath) {
        // delete item when swiped
        
        if let list = self.lists?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(list)
                }
            } catch {
                print("Error deleting list: \(error)")
            }
        }

    }
    
}

// MARK: - SearchBar methods

extension ListViewController: UISearchBarDelegate {
    
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

            lists = realm.objects(List.self).filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
            
            tableView.reloadData()
            
        }
    }

}
