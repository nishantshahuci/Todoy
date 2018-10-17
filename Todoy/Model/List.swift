//
//  List.swift
//  Todoy
//
//  Created by Nishant Shah on 10/14/18.
//  Copyright © 2018 Nishant Shah. All rights reserved.
//

import Foundation
import RealmSwift

class List: Object {
    
    @objc dynamic var name: String = ""
    let items = RealmSwift.List<Item>()
    
}
