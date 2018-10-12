//
//  ViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    
    // Search bar outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Selected list
    var selectedList: List? {
        didSet {
            loadItems()
        }
    }
    
    // Array of items for a list
    private var itemArray: [Item] = [Item]();
    
    // Core Data view context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a new cell at the row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        tableView.deselectRow(at: indexPath, animated: true);
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
    }
    
    // MARK: - Add new items
    
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
            
            // handle case where the text is null
            guard let text = textField.text else {
                return
            }
            
            if !text.isEmpty {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentList = self.selectedList
                self.itemArray.append(newItem)
            }
            
            self.saveItems()
            
        }
        alert.addAction(addAction)
        
        // action to cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper functions
    
    func saveItems() {
        // save items to CoreData
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(predicate: NSPredicate? = nil, sort: [NSSortDescriptor]? = nil) {
        // retrieve items from CoreData
        
        guard let listName = selectedList?.name else {
            fatalError("Failed to load list items")
        }
        
        // create request
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let listPredicate = NSPredicate(format: "parentList.name MATCHES %@", listName)
        
        // check for additional predicates
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, listPredicate])
        } else {
            request.predicate = listPredicate
        }
        
        // check for sort descriptors
        if let sortDescriptors = sort {
            request.sortDescriptors = sortDescriptors
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
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
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            let sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(predicate: predicate, sort: sortDescriptors)
        }
    }
    
}
