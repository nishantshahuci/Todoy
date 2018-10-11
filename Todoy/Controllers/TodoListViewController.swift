//
//  ViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    private var listArray: [Item] = [Item]();
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    //MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a new cell at the row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = listArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        tableView.deselectRow(at: indexPath, animated: true);
        listArray[indexPath.row].done = !listArray[indexPath.row].done
        saveItems()
    }
    
    //MARK: - Add new items
    
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
            
            // handle case where the text is empty
            guard let text = textField.text else {
                return
            }
            if !text.isEmpty {
                let newItem = Item(title: text)
                self.listArray.append(newItem)
            }
            
            self.saveItems()
            
        }
        alert.addAction(addAction)
        
        // action to cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Helper functions
    
    func saveItems() {
        // encode listArray and save to plist
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(listArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding array: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        // retrieve listArray from plist
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                listArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding array: \(error)")
            }
        }
    }
}

