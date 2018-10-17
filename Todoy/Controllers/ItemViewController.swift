//
//  ViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UITableViewController {
    
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
        
        customizeView()
        
    }
    
    // MARK: - Customize view function
    
    private func customizeView() {
        // customize searchbar and navbar views
        
        // set constant colors
        let navBarColor = self.navigationController?.navigationBar.barTintColor
        let navBarCgColor = self.navigationController?.navigationBar.barTintColor?.cgColor
        
        // create background image for navbar
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        if let color = navBarCgColor {
            context.setFillColor(color)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // change navigation background color
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = navBarColor
        
        // change search bar background color
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = image
        self.searchBar.barTintColor = navBarColor
        self.searchBar.layer.borderColor = navBarCgColor
        
        // add frame for tableview background
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        let bgView = UIView(frame: frame)
        bgView.backgroundColor = navBarColor
        self.tableView.insertSubview(bgView, at: 0)
        
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a new cell at the row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
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
    
    // MARK: - Helper functions
    
    func loadItems() {
        // retrieve items from Realm
        
        items = selectedList?.items.filter("TRUEPREDICATE")
        
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

            items = selectedList?.items.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData()
            
        }
    }

}
