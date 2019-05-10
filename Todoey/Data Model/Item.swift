//
//  Item.swift
//  Todoey
//
//  Created by Luca Grotto on 10/05/2019.
//  Copyright © 2019 Luca Grotto. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
   @objc dynamic var title: String = ""
   @objc dynamic var done: Bool = false
   @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
