//
//  ToDoData.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/28/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoData: Object {
    @objc dynamic var item : String = ""
    @objc dynamic var selected : Bool = false
    var parentCategory = LinkingObjects(fromType: CategoryData.self, property: "items")
}
