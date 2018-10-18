//
//  SwipeTableViewController.swift
//  Todoy
//
//  Created by Nishant Shah on 10/17/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Customize view function
    
    func customizeView(withSearchBar searchBar: UISearchBar) {
        // customize searchbar and navbar views
        
        // set constant colors
        let navBarColor = self.navigationController?.navigationBar.barTintColor
        let navBarCgColor = self.navigationController?.navigationBar.barTintColor?.cgColor
        
        // create background image for navbar
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        if let color = navBarCgColor {
            context.setFillColor(color)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // change navigation background color
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarPosition.any, barMetrics: UIBarMetrics.defaultPrompt)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = navBarColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // change search bar background color
        searchBar.isTranslucent = false
        searchBar.backgroundImage = image
        searchBar.barTintColor = navBarColor
        searchBar.layer.borderColor = navBarCgColor
        
        // add frame for tableview background
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        let bgView = UIView(frame: frame)
        bgView.backgroundColor = navBarColor
        self.tableView.insertSubview(bgView, at: 0)
        
    }
    
    // MARK: - TableView data source methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
        
    }
    
    // MARK: - SwipeTableCell delegate methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.updateModel(at: indexPath)
            
        }
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .reveal
        
        return options
        
    }
    
    // MARK: - Helper methods
    
    func updateModel(at indexPath: IndexPath) {
        // override this to update the model
    }

}
