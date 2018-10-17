//
//  Item.swift
//  Todoy
//
//  Created by Nishant Shah on 10/14/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentList = LinkingObjects(fromType: List.self, property: "items")
    
}
