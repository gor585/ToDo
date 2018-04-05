//
//  Category.swift
//  ToDo
//
//  Created by Jaroslav Stupinskyi on 04.04.18.
//  Copyright © 2018 Jaroslav Stupinskyi. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var rowColor: String = ""
    
    //Forward relationship:
    let items = List<Item>()
}
