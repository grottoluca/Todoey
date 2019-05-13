//
//  Category.swift
//  Todoey
//
//  Created by Luca Grotto on 10/05/2019.
//  Copyright © 2019 Luca Grotto. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
    
}
