//
//  Category.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/28/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryData: Object {
    @objc dynamic var name : String = ""
    var items = List<ToDoData>()
}
