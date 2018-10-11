//
//  ViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit

class TodoListController: UITableViewController {
    
    let listArray = ["go home", "do work", "plan vacation"];

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows in the section
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a new cell at the row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = listArray[indexPath.row]
        return cell
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle user selecting an item in the list
        
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }

}

