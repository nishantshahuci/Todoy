//
//  Item.swift
//  Todoy
//
//  Created by Nishant Shah on 10/11/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import Foundation

class Item: Codable {
    
    var title: String = ""
    var done: Bool = false
    
    init() {}
    
    init(title: String) {
        self.title = title
    }
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
    
}
