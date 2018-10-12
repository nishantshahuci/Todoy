//
//  CategoryViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    // Search bar outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Array of lists
    var listArray: [List] = [List]()
    
    // Core Data view context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.backgroundImage = UIImage()
        
        loadItems()
    }

    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return
        
        return listArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return new cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        cell.textLabel?.text = listArray[indexPath.row].name
        
        return cell
        
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! ItemViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedList = listArray[indexPath.row]
        }
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
                let newList = List(context: self.context)
                newList.name = text
                self.listArray.append(newList)
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
        // save list to CoreData
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<List> = List.fetchRequest()) {
        // retrieve lists from CoreData
        
        do {
            listArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
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
            
            let request: NSFetchRequest<List> = List.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            loadItems(with: request)
        }
    }
    
}
