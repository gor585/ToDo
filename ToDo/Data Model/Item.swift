//
//  Item.swift
//  ToDo
//
//  Created by Jaroslav Stupinskyi on 04.04.18.
//  Copyright © 2018 Jaroslav Stupinskyi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    @objc dynamic var dateCreated: Date?
    
    @objc dynamic var rowColor: String = ""
    
    //Inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
